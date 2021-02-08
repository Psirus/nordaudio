{.passL: "-lportaudio".}
{.pragma: paHeader, header: "portaudio.h"}

type
  DeviceIndex* {.importc: "PaDeviceIndex", paHeader.} = cint ## \
  ## The type used to refer to audio devices. Values of this type usually range
  ## from 0 to (getDeviceCount()-1), and may also take on the paNoDevice and
  ## paUseHostApiSpecificDeviceSpecification values.
  ##   
  ## See also:
  ## `getDeviceCount<#getDeviceCount>`_, `paNoDevice<#paNoDevice>`_,
  ## `paUseHostApiSpecificDeviceSpecification<#paUseHostApiSpecificDeviceSpecification>`_
  SampleFormat* {.importc: "Pa$1", paHeader.} = culong
  Time* {.importc: "Pa$1", paHeader.} = cdouble
  Stream* {.importc: "Pa$1", paHeader.} = object
  StreamFlags* {.importc: "Pa$1", paHeader.} = culong
  StreamCallbackFlags* {.importc: "Pa$1", paHeader.} = culong
  Error* {.importc: "Pa$1", paHeader.} = cint
  HostApiIndex* {.importc: "Pa$1", paHeader.} = cint

  StreamCallbackTimeInfo* {.bycopy, importc: "struct Pa$1", paHeader.} = object
    inputBufferAdcTime*: Time
    currentTime*: Time
    outputBufferDacTime*: Time

  StreamParameters* {.bycopy, importc: "struct Pa$1", paHeader.} = object
    device*: DeviceIndex
    channelCount*: cint
    sampleFormat*: SampleFormat
    suggestedLatency*: Time
    hostApiSpecificStreamInfo*: pointer

  DeviceInfo* {.bycopy, importc: "struct Pa$1", paHeader.} = object
    structVersion*: cint
    name*: cstring
    hostApi*: HostApiIndex
    maxInputChannels*: cint
    maxOutputChannels*: cint
    defaultLowInputLatency*: Time
    defaultLowOutputLatency*: Time
    defaultHighInputLatency*: Time
    defaultHighOutputLatency*: Time
    defaultSampleRate*: cdouble

  StreamCallback* = proc (input: pointer;
      output: pointer; frameCount: culong;
      timeInfo: ptr StreamCallbackTimeInfo;
      statusFlags: StreamCallbackFlags; userData: pointer): cint {.cdecl.}

  StreamFinishedCallback* {.importc: "Pa$1", paHeader.} = proc (userData: pointer) {.cdecl.}
  
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

proc initialize*(): Error {.importc: "Pa_Initialize", paHeader, cdecl.}
proc getDefaultOutputDevice*(): DeviceIndex {.importc: "Pa_GetDefaultOutputDevice", paHeader, cdecl.}
proc getDeviceInfo*(device: DeviceIndex): ptr DeviceInfo {.importc: "Pa_GetDeviceInfo", paHeader, cdecl.}
proc openStream*(stream: ptr ptr Stream;
                 inputParameters: ptr StreamParameters;
                 outputParameters: ptr StreamParameters; sampleRate: cdouble;
                 framesPerBuffer: culong; streamFlags: StreamFlags;
                 streamCallback: StreamCallback; userData: pointer): Error {.importc: "Pa_OpenStream", paHeader, cdecl.}
proc setStreamFinishedCallback*(stream: ptr Stream;
  streamFinishedCallback: StreamFinishedCallback): Error {.importc: "Pa_SetStreamFinishedCallback", paHeader, cdecl.}
proc startStream*(stream: ptr Stream): Error {.importc: "Pa_StartStream", paHeader, cdecl.}
proc stopStream*(stream: ptr Stream): Error {.importc: "Pa_StopStream", paHeader, cdecl.}
proc closeStream*(stream: ptr Stream): Error {.importc: "Pa_CloseStream", paHeader, cdecl.}
proc terminate*(): Error {.importc: "Pa_Terminate", paHeader, cdecl.}
proc getStreamCpuLoad*(stream: ptr Stream): cdouble {.importc: "Pa_GetStreamCpuLoad", paHeader, cdecl.}
