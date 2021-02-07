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
    time: int

proc callback(output: var openarray[float32], data: var TestData) =
  for i in countup(0, output.len-1, 2):
    let amp = data.time / (64*2000)
    output[i] = amp * data.sine[data.left_phase]
    output[i+1] = amp * data.sine[data.right_phase]

    inc(data.left_phase, 1)
    if data.left_phase >= TABLE_SIZE:
      dec(data.left_phase, TABLE_SIZE)
    inc(data.right_phase, 3)
    if data.right_phase >= TABLE_SIZE:
      dec(data.right_phase, TABLE_SIZE)
    inc(data.time)

proc cCallback*(inputBuffer: pointer; outputBuffer: pointer;
                framesPerBuffer: culong;
                timeInfo: ptr StreamCallbackTimeInfo;
                statusFlags: StreamCallbackFlags; userData: pointer): cint {.cdecl.} =
  var data: ptr TestData = cast[ptr TestData](userData)
  var tmp = cast[ptr UncheckedArray[float32]](outputBuffer)
  callback(toOpenArray(tmp, 0, 2*cast[int](framesPerBuffer)-1), data[])
  return 0

var
  outputParameters: StreamParameters
  stream: ptr Stream
  data: TestData

var i = 0
while i < TABLE_SIZE:
  data.sine[i] = sin(2.0 * PI * (i / TABLE_SIZE))
  inc(i)

proc dup(oldfd: FileHandle): FileHandle {.importc, header: "unistd.h".}
proc dup2(oldfd: FileHandle, newfd: FileHandle): cint {.importc, header: "unistd.h".}
let tmpFileName = "portaudio_log.txt"

template captureStderr*(body: untyped) =
  var stdout_fileno = stderr.getFileHandle()
  var stdout_dupfd = dup(stdout_fileno)
  var tmp_file: File = open(tmpFileName, fmWrite)
  var tmp_file_fd: FileHandle = tmp_file.getFileHandle()
  discard dup2(tmp_file_fd, stdout_fileno)
  body
  tmp_file.flushFile()
  tmp_file.close()
  discard dup2(stdout_dupfd, stdout_fileno)

data.left_phase = 0
data.right_phase = 0
data.time = 0
captureStdErr:
  discard initialize()
outputParameters.device = getDefaultOutputDevice()
outputParameters.channelCount = 2
outputParameters.sampleFormat = paFloat32
outputParameters.suggestedLatency = getDeviceInfo(outputParameters.device).defaultLowOutputLatency
outputParameters.hostApiSpecificStreamInfo = nil

discard openStream(addr(stream), nil, addr(outputParameters), SAMPLE_RATE, FRAMES_PER_BUFFER, paClipOff, cCallback, addr(data))

discard startStream(stream)
sleep(1000)
echo getStreamCpuLoad(stream)
sleep(1000)
discard stopStream(stream)
terminate()
