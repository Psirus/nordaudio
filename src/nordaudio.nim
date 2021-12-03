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

  StreamCallbackTimeInfo* {.bycopy, importc: "struct Pa$1", paHeader.} = object ## \
  ## Timing information for the buffers passed to the stream callback.
  ##
  ## Time values are expressed in seconds and are synchronised with the time base
  ## used by `getStreamTime()<#getStreamTime,ptr.Stream>`_ for the associated stream.
  ##
  ## See also: `StreamCallback<#StreamCallback>`_
    inputBufferAdcTime*: Time ## The time when the first sample of the input buffer was captured at the ADC input
    currentTime*: Time ## The time when the stream callback was invoked
    outputBufferDacTime*: Time ## The time when the first sample of the output buffer will output at the DAC

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

  StreamCallbackResult* {.size: sizeof(cint).} = enum
    paContinue = 0, paComplete = 1, paAbort = 2

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
proc getDefaultInputDevice*(): DeviceIndex {.importc: "Pa_GetDefaultInputDevice", paHeader, cdecl.}
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
proc getStreamTime*(stream: ptr Stream): Time {.importc: "Pa_GetStreamTime", paHeader, cdecl.}
proc getDeviceCount*(): DeviceIndex {.importc: "Pa_GetDeviceCount", paHeader, cdecl.}
proc isStreamActive*(stream: ptr Stream): Error {.importc: "Pa_IsStreamActive", paHeader, cdecl.}
