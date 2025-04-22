#-----------------------------------------------------------------------------
# Applications directory
#-----------------------------------------------------------------------------
if(NOT DEFINED TBoxPulse_APPLICATIONS_DIR)
  set(TBoxPulse_APPLICATIONS_DIR "${TBoxPulse_SOURCE_DIR}/Applications")
endif()

if(NOT DEFINED TBoxPulse_MAIN_PROJECT)
  set(TBoxPulse_MAIN_PROJECT TBoxPulse CACHE STRING "Main Project Name")
endif()
