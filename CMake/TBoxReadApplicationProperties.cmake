
function(TBoxReadApplicationProperties)
  set(options
    )
  set(oneValueArgs
    PROJECT_NAME
    PROPERTIES_VAR
    )
  set(multiValueArgs
    )
  cmake_parse_arguments(MY
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )
  message("====================================================================")
  message("Read Application Properties File:")
  message("Debug: PROJECT_NAME = ${PROJECT_NAME}")
  message("Debug: TBoxPulse_APPLICATIONS_DIR = \"${TBoxPulse_APPLICATIONS_DIR}\"")
  # Check if expected global variables are defined
  set(expected_defined_vars
    TBoxPulse_APPLICATIONS_DIR
    )
  foreach(var ${expected_defined_vars})
    if(NOT DEFINED ${var})
      message(FATAL_ERROR "Variable ${var} is not defined !")
    endif()
  endforeach()

  # Set default
  if(NOT DEFINED MY_PROJECT_NAME)
    set(MY_PROJECT_NAME "${PROJECT_NAME}")
  endif()

  # Sanity checks
  if(NOT EXISTS ${TBoxPulse_APPLICATIONS_DIR})
    message(FATAL_ERROR "TBoxPulse_APPLICATIONS_DIR is defined but corresponds to a nonexistent directory [${TBoxPulse_APPLICATIONS_DIR}]")
  endif()
  if(NOT EXISTS ${TBoxPulse_APPLICATIONS_DIR}/${MY_PROJECT_NAME})
    message(FATAL_ERROR "PROJECT_NAME corresponds to a nonexistent application directory [${TBoxPulse_APPLICATIONS_DIR}/${MY_PROJECT_NAME}]")
  endif()
  set(property_file ${TBoxPulse_APPLICATIONS_DIR}/${MY_PROJECT_NAME}/TBoxPulse-application-properties.cmake)
  if(NOT EXISTS ${property_file})
    message(FATAL_ERROR "Couldn't find property file 'TBoxPulse-application-properties.cmake' in directory [${TBoxPulse_APPLICATIONS_DIR}/${MY_PROJECT_NAME}]")
  endif()

  include(${property_file})

  set(properties
    APPLICATION_NAME

    VERSION_MAJOR
    VERSION_MINOR
    VERSION_PATCH
    REVISION_TYPE
    WC_COMMIT_COUNT_OFFSET

    DESCRIPTION_SUMMARY
    DESCRIPTION_FILE

    LAUNCHER_SPLASHSCREEN_FILE
    LINUX_ICON_FILE
    WIN_ICON_FILE

    LICENSE_FILE
    )

  message("Debug: Loading property file: ${property_file}")
  message("Debug: MY_PROJECT_NAME = ${MY_PROJECT_NAME}")

  foreach(property_name IN LISTS properties)
      message("Debug: Setting ${MY_PROJECT_NAME}_${property_name} = ${${property_name}}")
  endforeach()

  foreach(property_name IN LISTS properties)
    # Set property value if not already defined in caller scope
    if(NOT DEFINED ${MY_PROJECT_NAME}_${property_name})
      set(default_value ${${property_name}})
      set(${MY_PROJECT_NAME}_${property_name} "${default_value}" PARENT_SCOPE)
    endif()
    mark_as_advanced(${MY_PROJECT_NAME}_${property_name})
  endforeach()

  if(DEFINED MY_PROPERTIES_VAR)
    set(${MY_PROPERTIES_VAR} ${properties} PARENT_SCOPE)
  endif()
endfunction()
