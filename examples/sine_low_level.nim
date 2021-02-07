import os
import math
import ../portaudio

const
  SAMPLE_RATE = 44100
  FRAMES_PER_BUFFER = 64
  TABLE_SIZE = 200

type
  TestData = object
    sine: array[TABLE_SIZE, float32]
    left_phase: int
    right_phase: int


template `+`[T](p: ptr T, off: int): ptr T =
  cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

template `+=`[T](p: ptr T, off: int) =
  p = p + off

proc patestCallback*(inputBuffer: pointer; outputBuffer: pointer;
                    framesPerBuffer: culong;
                    timeInfo: ptr StreamCallbackTimeInfo;
                    statusFlags: StreamCallbackFlags; userData: pointer): cint {.cdecl.} =
  var data: ptr TestData = cast[ptr TestData](userData)
  var output: ptr cfloat = cast[ptr cfloat](outputBuffer)
  var i: culong

  i = 0
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
    inc(i)
  return 0

var
  outputParameters: StreamParameters
  stream: ptr Stream
  data: TestData

var i = 0
while i < TABLE_SIZE:
  data.sine[i] = sin(2.0 * PI * (i / TABLE_SIZE))
  inc(i)

data.left_phase = 0
data.right_phase = 0
discard initialize()
outputParameters.device = getDefaultOutputDevice()
outputParameters.channelCount = 2
outputParameters.sampleFormat = paFloat32
outputParameters.suggestedLatency = getDeviceInfo(outputParameters.device).defaultLowOutputLatency
outputParameters.hostApiSpecificStreamInfo = nil

discard openStream(addr(stream), nil, addr(outputParameters), SAMPLE_RATE, FRAMES_PER_BUFFER, paClipOff, patestCallback, addr(data))

discard startStream(stream)
sleep(1000)
echo getStreamCpuLoad(stream)
sleep(1000)
discard stopStream(stream)
terminate()
