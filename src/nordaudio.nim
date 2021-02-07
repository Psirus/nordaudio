{.passL: "-lportaudio".}

type
  DeviceIndex* = cint
  SampleFormat* = culong
  Time* = cdouble
  Stream* = pointer
  StreamFlags* = culong
  StreamCallbackFlags* = culong
  Error* = cint
  StreamCallbackTimeInfo* {.bycopy.} = object
    inputBufferAdcTime*: Time
    currentTime*: Time
    outputBufferDacTime*: Time

  StreamParameters* {.importc: "struct PaStreamParameters", header: "portaudio.h".} = object
    device*: DeviceIndex
    channelCount*: cint
    sampleFormat*: SampleFormat
    suggestedLatency*: Time
    hostApiSpecificStreamInfo*: pointer

  DeviceInfo* {.importc: "struct PaDeviceInfo", header: "portaudio.h".} = object
    defaultLowOutputLatency*: Time

  StreamCallback* {.importc: "PaStreamCallback", header: "portaudio.h".} = proc (input: pointer;
      output: pointer; frameCount: culong;
      timeInfo: ptr StreamCallbackTimeInfo;
      statusFlags: StreamCallbackFlags; userData: pointer): cint {.cdecl.}

  StreamFinishedCallback* {.header: "portaudio.h", importc: "PaStreamFinishedCallback"} = proc (userData: pointer) {.cdecl.}

    
const
  paFloat32* = cast[SampleFormat](0x00000001)
  paInt32* = cast[SampleFormat](0x00000002)
  paInt24* = cast[SampleFormat](0x00000004)
  paInt16* = cast[SampleFormat](0x00000008)
  paInt8* = cast[SampleFormat](0x00000010)
  paUInt8* = cast[SampleFormat](0x00000020)
  paCustomFormat* = cast[SampleFormat](0x00010000)
  paNonInterleaved* = cast[SampleFormat](0x80000000)

  paNoFlag* = cast[StreamFlags](0)
  paClipOff* = cast[StreamFlags](0x00000001)
  paDitherOff* = cast[StreamFlags](0x00000002)
  paNeverDropInput* = cast[StreamFlags](0x00000004)
  paPrimeOutputBuffersUsingStreamCallback* = cast[StreamFlags](0x00000008)
  paPlatformSpecificFlags* = cast[StreamFlags](0xFFFF0000)

proc initialize*(): Error {.header: "portaudio.h", importc: "Pa_Initialize"}
proc getDefaultOutputDevice*(): DeviceIndex {.header: "portaudio.h", importc: "Pa_GetDefaultOutputDevice"}
proc getDeviceInfo*(device: DeviceIndex): ptr DeviceInfo {.header: "portaudio.h", importc: "Pa_GetDeviceInfo"}
proc openStream*(stream: Stream;
                 inputParameters: ptr StreamParameters;
                 outputParameters: ptr StreamParameters; sampleRate: cdouble;
                 framesPerBuffer: culong; streamFlags: StreamFlags;
                 streamCallback: StreamCallback; userData: pointer): Error {.header: "portaudio.h", importc: "Pa_OpenStream", cdecl.}
proc startStream*(stream: Stream): Error {.header: "portaudio.h", importc: "Pa_StartStream"}
proc stopStream*(stream: Stream): Error {.header: "portaudio.h", importc: "Pa_StopStream"}
proc terminate*() {.header: "portaudio.h", importc: "Pa_Terminate"}
proc getStreamCpuLoad*(stream: Stream): cdouble {.header: "portaudio.h", importc: "Pa_GetStreamCpuLoad"}
