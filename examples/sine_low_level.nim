import os, math, strformat
import nordaudio

const
  SAMPLE_RATE = 44100.0
  FRAMES_PER_BUFFER = 64
  NUM_SECONDS = 5
  TABLE_SIZE = 200

type
  TestData = object
    sine: array[TABLE_SIZE, float32]
    left_phase: int
    right_phase: int
    message: string


# Bit of pointer arithmetic needed to closely replicate PortAudio example
template `+`[T](p: ptr T, off: int): ptr T =
  cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

template `+=`[T](p: ptr T, off: int) =
  p = p + off

proc testCallback*(inputBuffer: pointer; outputBuffer: pointer;
                    framesPerBuffer: culong;
                    timeInfo: ptr StreamCallbackTimeInfo;
                    statusFlags: StreamCallbackFlags; userData: pointer): cint {.cdecl.} =
  var data = cast[ptr TestData](userData)
  var output = cast[ptr cfloat](outputBuffer)

  var i: culong = 0
  while i < framesPerBuffer:
    output[] = data.sine[data.left_phase]
    output += 1
    output[] = data.sine[data.right_phase]
    output += 1

    inc(data.left_phase, 1)
    if data.left_phase >= TABLE_SIZE:
      dec(data.left_phase, TABLE_SIZE)
    inc(data.right_phase, 3)
    if data.right_phase >= TABLE_SIZE:
      dec(data.right_phase, TABLE_SIZE)

    inc i
  return 0

proc streamFinished(userData: pointer) {.cdecl.} =
  var data = cast[ptr TestData](userData)
  echo "Stream Completed: ", data.message

var
  outputParameters: StreamParameters
  stream: ptr Stream
  data: TestData
  i = 0

echo fmt"nordaudio Test: output sine wave. SR = {SAMPLE_RATE}, BufSize = {FRAMES_PER_BUFFER}"
while i < TABLE_SIZE:
  data.sine[i] = sin(2.0 * PI * (i / TABLE_SIZE))
  inc i

data.left_phase = 0
data.right_phase = 0

discard initialize()
outputParameters.device = getDefaultOutputDevice()
outputParameters.channelCount = 2
outputParameters.sampleFormat = paFloat32
outputParameters.suggestedLatency = getDeviceInfo(outputParameters.device).defaultLowOutputLatency
outputParameters.hostApiSpecificStreamInfo = nil

discard openStream(addr(stream), nil, addr(outputParameters), SAMPLE_RATE, FRAMES_PER_BUFFER, paClipOff, testCallback, addr(data))
data.message = "No Message"
discard setStreamFinishedCallback(stream, streamFinished)

discard startStream(stream)
echo fmt"Play for {NUM_SECONDS} seconds."
sleep(NUM_SECONDS * 1000)
discard stopStream(stream)
discard closeStream(stream)
discard terminate()
