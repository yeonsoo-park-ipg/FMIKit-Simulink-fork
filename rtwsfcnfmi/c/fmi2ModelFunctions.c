/*****************************************************************
 *  Copyright (c) Dassault Systemes. All rights reserved.        *
 *  This file is part of FMIKit. See LICENSE.txt in the project  *
 *  root for license information.                                *
 *****************************************************************/

/*
-----------------------------------------------------------
	Implementation of FMI 2.0 ME on top of C code
	generated by Simulink Coder S-function target.
-----------------------------------------------------------
*/

#include <string.h>

/* FMI memory allocation with zero initialization */
extern void* allocateMemory0(size_t nobj, size_t size);

/* Model-specific code used by wrapper, output of Simulink Coder FMI code generation */
#include "sfcn_fmi.h"

/* Forward declarations of FMI function implementation */
#include "fmi2ModelFunctions_.h"

/* -----------------------------------------------------------
   ----------------- FMI function definitions ----------------
   ----------------------------------------------------------- */

const char* fmi2GetTypesPlatform()
{
	return fmi2TypesPlatform;
}

const char* fmi2GetVersion()
{
	return fmi2Version;
}

fmi2Status fmi2SetDebugLogging(fmi2Component c, fmi2Boolean loggingOn, size_t nCategories, const fmi2String categories[])
{
	return fmi2SetDebugLogging_(c, loggingOn, nCategories, categories);
}

fmi2Component fmi2Instantiate(fmi2String	instanceName,
								fmi2Type	fmuType,
								fmi2String	GUID,
								fmi2String	fmuResourceLocation,
								const fmi2CallbackFunctions* functions,
								fmi2Boolean	visible,
								fmi2Boolean	loggingOn)
{
	fmi2Component comp = fmi2Instantiate_(instanceName, fmuType, GUID, fmuResourceLocation, functions, visible, loggingOn);
	return comp;
}

void fmi2FreeInstance(fmi2Component c)
{
	fmi2FreeInstance_(c);
}

fmi2Status fmi2SetupExperiment(fmi2Component c,
										fmi2Boolean toleranceDefined,
										fmi2Real tolerance,
										fmi2Real startTime,
										fmi2Boolean stopTimeDefined,
										fmi2Real stopTime)
{
	return fmi2SetupExperiment_(c, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime);
}

fmi2Status fmi2EnterInitializationMode(fmi2Component c)
{
	return fmi2EnterInitializationMode_(c);
}

fmi2Status fmi2ExitInitializationMode(fmi2Component c)
{
	return fmi2ExitInitializationMode_(c);
}

fmi2Status fmi2Terminate(fmi2Component c)
{
	return fmi2Terminate_(c);
}

fmi2Status fmi2Reset(fmi2Component c)
{
	return fmi2Reset_(c);
}

fmi2Status fmi2GetReal(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, fmi2Real value[])
{
	return fmi2GetReal_(c, vr, nvr, value);
}

fmi2Status fmi2GetInteger(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, fmi2Integer value[])
{
	return fmi2GetInteger_(c, vr, nvr, value);
}

fmi2Status fmi2GetBoolean(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, fmi2Boolean value[])
{
	return fmi2GetBoolean_(c, vr, nvr, value);
}

fmi2Status fmi2GetString(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, fmi2String  value[])
{
	return fmi2GetString_(c, vr, nvr, value);
}

fmi2Status fmi2SetReal(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, const fmi2Real value[])
{
	return fmi2SetReal_(c, vr, nvr, value);
}

fmi2Status fmi2SetInteger(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, const fmi2Integer value[])
{
	return fmi2SetInteger_(c, vr, nvr, value);
}

fmi2Status fmi2SetBoolean(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, const fmi2Boolean value[])
{
	return fmi2SetBoolean_(c, vr, nvr, value);
}

fmi2Status fmi2SetString(fmi2Component c, const fmi2ValueReference vr[], size_t nvr, const fmi2String  value[])
{
	return fmi2SetString_(c, vr, nvr, value);
}

fmi2Status fmi2GetFMUstate(fmi2Component c, fmi2FMUstate* FMUstate)
{
	return fmi2GetFMUstate_(c, FMUstate);
}

fmi2Status fmi2SetFMUstate(fmi2Component c, fmi2FMUstate FMUstate)
{
	return fmi2SetFMUstate_(c, FMUstate);
}

fmi2Status fmi2FreeFMUstate(fmi2Component c, fmi2FMUstate* FMUstate)
{
	return fmi2FreeFMUstate_(c, FMUstate);
}

fmi2Status fmi2SerializedFMUstateSize(fmi2Component c, fmi2FMUstate FMUstate, size_t* size)
{
	return fmi2SerializedFMUstateSize_(c, FMUstate, size);
}

fmi2Status fmi2SerializeFMUstate(fmi2Component c, fmi2FMUstate FMUstate, fmi2Byte serializedState[], size_t size)
{
	return fmi2SerializeFMUstate_(c, FMUstate, serializedState, size);
}

fmi2Status fmi2DeSerializeFMUstate(fmi2Component c, const fmi2Byte serializedState[], size_t size, fmi2FMUstate* FMUstate)
{
	return fmi2DeSerializeFMUstate_(c, serializedState, size, FMUstate);
}

fmi2Status fmi2GetDirectionalDerivative(fmi2Component c, const fmi2ValueReference vUnknown_ref[], size_t nUnknown,
                                                         const fmi2ValueReference vKnown_ref[], size_t nKnown,
                                                         const fmi2Real dvKnown[],
														       fmi2Real dvUnknown[])
{
	return fmi2GetDirectionalDerivative_(c, vUnknown_ref, nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown);
}

/* Model Exchange functions */
fmi2Status fmi2EnterEventMode(fmi2Component c)
{
	return fmi2EnterEventMode_(c);
}

fmi2Status fmi2NewDiscreteStates(fmi2Component c, fmi2EventInfo* eventInfo)
{
	return fmi2NewDiscreteStates_(c, eventInfo);
}

fmi2Status fmi2EnterContinuousTimeMode(fmi2Component c)
{
	return fmi2EnterContinuousTimeMode_(c);
}

fmi2Status fmi2CompletedIntegratorStep(fmi2Component c, fmi2Boolean noSetFMUStatePriorToCurrentPoint,
										fmi2Boolean* enterEventMode, fmi2Boolean* terminateSimulation)
{
	return fmi2CompletedIntegratorStep_(c, noSetFMUStatePriorToCurrentPoint, enterEventMode, terminateSimulation);
}

fmi2Status fmi2SetTime(fmi2Component c, fmi2Real time)
{
	return fmi2SetTime_(c, time);
}

fmi2Status fmi2SetContinuousStates(fmi2Component c, const fmi2Real x[], size_t nx)
{
	return fmi2SetContinuousStates_(c, x, nx);
}

fmi2Status fmi2GetDerivatives(fmi2Component c, fmi2Real derivatives[], size_t nx)
{
	return fmi2GetDerivatives_(c, derivatives, nx);
}

fmi2Status fmi2GetEventIndicators(fmi2Component c, fmi2Real eventIndicators[], size_t ni)
{
	return fmi2GetEventIndicators_(c, eventIndicators, ni);
}

fmi2Status fmi2GetContinuousStates(fmi2Component c, fmi2Real x[], size_t nx)
{
	return fmi2GetContinuousStates_(c, x, nx);
}

fmi2Status fmi2GetNominalsOfContinuousStates(fmi2Component c, fmi2Real x_nominal[], size_t nx)
{
	return fmi2GetNominalsOfContinuousStates_(c, x_nominal, nx);
}
