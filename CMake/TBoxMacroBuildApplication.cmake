
macro(TBoxMacroBuildAppLibrary)    
  set(options "")
  set(oneValueArgs
      NAME
      APPLICATION_NAME
      DESCRIPTION_SUMMARY
      DESCRIPTION_FILE
      EXPORT_DIRECTIVE
      FOLDER)
  set(multiValueArgs SRCS
      MOC_SRCS
      UI_SRCS
      RESOURCES)

  cmake_parse_arguments(TBoxPulseAppLib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})
  message("------------------------------------------------------------------------------------------")
  message("Debug: Configuring application library:")
  message("Debug: TBoxPulseAppLib_NAME = [${TBoxPulseAppLib_NAME}]")
  message("Debug: TBoxPulseAppLib_APPLICATION_NAME = [${TBoxPulseAppLib_APPLICATION_NAME}]")
  message("Debug: TBoxPulseAppLib_DESCRIPTION_SUMMARY = [${TBoxPulseAppLib_DESCRIPTION_SUMMARY}]")
  message("Debug: TBoxPulseAppLib_DESCRIPTION_FILE = [${TBoxPulseAppLib_DESCRIPTION_FILE}]")
  message("------------------------------------------------------------------------------------------")

  #-------------------------------------------------------------------------
  #Sanidy checks
  #-------------------------------------------------------------------------
  if(TBoxPulseAppLib_UNPARSE_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to TBoxPulseMacroBuildAppLibrary() : \"${TBoxPulseAppLib_UNPARSE_ARGUMENTS}\"")
  endif()

  set(expected_defined_vars NAME EXPORT_DIRECTIVE  DESCRIPTION_SUMMARY)
  foreach(var ${expected_defined_vars})
    if(NOT DEFINED TBoxPulseAppLib_${var})
      message(FATAL_ERROR "${var} is mandetory")
    endif()
  endforeach()

  set(expected_existing_vars DESCRIPTION_FILE)
  foreach(var ${expected_existing_vars})
    if(NOT DEFINED TBoxPulseAppLib_${var})
      message(FATAL_ERROR "${var} is mandetory")
      endif()
  endforeach()

  if(NOT DEFINED TBoxPulse_INSTALL_NO_DEVELOPMENT)
      message(SEND_ERROR "TBoxPulse_INSTALL_NO_DEVELOPMENT" is mandatory)
  endif()

  if(NOT DEFINED TBoxPulseAppLib_APPLICANTION_NANE)
      set(TBoxPulseAppLib_APPLICATION_NAME ${TBoxPulseAppLib_NAME})
  endif()

  #-------------------------------------------------------------------------------
  #Defined library name
  #-------------------------------------------------------------------------------
  set(lib_name ${TBoxPulseAppLib_NAME})


  #-------------------------------------------------------------------------------
  #Include dirs
  #--------------------------------------------------------------------------------
  set(include_dirs
      ${CMAKE_CERRENT_SOURCE_DIR}
      ${CMAKE_CURRENT_BINARY_DIR}
      ${TBoxPulse_Base_INCLUDE_DIRS}
      ${TBoxPulse_SOURCE_DIR}/Base/QTApp  # 添加这一行
      ${TBoxPulseAppLib_INCLUDE_DIRECTORY})

  include_directories(include_dirs)

  #---------------------------------------------------------------------------------
  #Update TBoxPulse_Base_INCLUDE_DIRS
  #---------------------------------------------------------------------------------

  #---------------------------------------------------------------------------------
  #Configure
  #---------------------------------------------------------------------------------
  set(MY_LIBRARY_EXPORT_DITECTORY ${TBoxPulseAppLib_EXPORT_DIRECTORY})
  set(MY_EXPORT_HEADER_PREFIX ${TBoxPulseAppLib_NAME})
  set(MY_LIBNAME ${lib_name})

  configure_file(
      ${TBoxPulse_SOURCE_DIR}/CMake/qTBoxPulseExport.h.in
      ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h)
  set(dynamicHeaders
      "${dynamicHears};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")

  #-----------------------------------------------------------------------------------
  #Sources
  #-----------------------------------------------------------------------------------
  set(moc_options_ OPTIONS -DTBoxPulse_HAVE_QT6)
  QT6_WRAP_CPP(TBoxPulseAppLib_MOC_OUTPUT ${TBoxPulseAppLib_MOC_SRCS} ${moc_options_})
  QT6_WRAP_UI(TBOXPULSELIB_UI_CXX ${TBoxPulseAppLib_UI_SRCS})
  if(DEFINED TBoxPulseAppLib_RESOURCES)
      QT6_ADD_RESOURCES(TBoxPulseAppLib_QRC_SRCS ${TBoxPulseAppLib_RESOURCES})
  endif()

  set_source_files_properties(
      ${TBOXPULSELIB_UI_CXX}
      ${TBoxPulseAppLib_MOC_OUTPUT}
      ${TBoxPulseAppLib_QRC_SRCS}
      WRAP_EXCLUDE)

  # --------------------------------------------------------------------------
  # Source groups
  # --------------------------------------------------------------------------

  # --------------------------------------------------------------------------
  # Translation
  # --------------------------------------------------------------------------
  if(TBoxPulseAppLib_BUILD_I18N_SUPPORT)

   else()
     set(QM_OUTPUT_FILES )
   endif()

   # --------------------------------------------------------------------------
   # Build the library
   # --------------------------------------------------------------------------
   add_library(${lib_name}
     ${TBoxPulseAppLib_SRCS}
     ${TBoxPulseAppLib_MOC_OUTPUT}
     ${TBoxPulseAppLib_UI_CXX}
     ${TBoxPulseAppLib_QRC_SRCS}
     ${QM_OUTPUT_FILES})

    #set_target_properties(${lib_name} PROPERTIES LABELS ${lib_name})


    # Apply user-defined properties to the library target.
    #if(TBoxPulseAppLib_LIBRARY_PROPERTIES)
    #  set_target_properties(${lib_name} PROPERTIES ${TBoxPulseAppLib_LIBRARY_PROPERTIES})
    #endif()

    target_link_libraries(${lib_name}
      Qt6::Core
      Qt6::Widgets
      qTBoxPulseBaseQTApp
      ${TBoxPulseAppLib_TARGET_LIBRARIES}
      )

    # Folder

    #set_target_properties(${lib_name} PROPERTIES FOLDER ${TBoxPulseAppLib_FOLDER})

    #-----------------------------------------------------------------------------
    # Install library
    #-----------------------------------------------------------------------------
    message("Debug : TBoxPulse_INSTALL_BIN_DIR = ${TBoxPulse_INSTALL_BIN_DIR}")
    message("Debug : TBoxPulse_INSTALL_LIB_DIR = ${TBoxPulse_INSTALL_LIB_DIR}")

    install(TARGETS ${lib_name}
      RUNTIME DESTINATION ${TBoxPulse_INSTALL_BIN_DIR} COMPONENT RuntimeLibraries
      LIBRARY DESTINATION ${TBoxPulse_INSTALL_LIB_DIR} COMPONENT RuntimeLibraries
      ARCHIVE DESTINATION ${TBoxPulse_INSTALL_LIB_DIR} COMPONENT Development
    )

   # --------------------------------------------------------------------------
   # Install headers
   # --------------------------------------------------------------------------
   if(NOT TBoxPulse_INSTALL_NO_DEVELOPMENT)
       # Install headers
       file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
       install(FILES
           ${headers}
           ${dynamicHeaders}
           DESTINATION ${TBoxPulse_INSTALL_INCLUDE_DIR}/${lib_name} COMPONENT Development
       )
    endif()

    # --------------------------------------------------------------------------
    # Export target
    # --------------------------------------------------------------------------
    #set_property(GLOBAL APPEND PROPERTY Slicer_TARGETS ${TBoxPulseAppLib_NAME})


endmacro()


#--------------------------------------------------------------------------------------------------
# TBoxPulseMacroBuildApplication
#--------------------------------------------------------------------------------------------------

macro(TBoxMacroBuildApplication)
  set(options)
  set(oneValueArgs
    NAME
    FOLDER
    APPLICATION_NAME

    DEFAULT_SETTINGS_FILE
    SPLASHSCREEN_ENABLED
    LAUNCHER_SPLASHSCREEN_FILE
    LINUX_ICON_FILE
    WIN_ICON_FILE
    LICENSE_FILE

    TARGET_NAME_VAR

    APPLICATION_DEFAULT_ARGUMENTS # space separated list
    )

    set(multiValueArgs
        SRCS
        INCLUDE_DIRECTORIES
        TARGET_LIBRARIES
    )

  cmake_parse_arguments(TBoxPulseApp "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})


  #----------------------------------------------------------------------------------------------------
  #Sanity checks
  #----------------------------------------------------------------------------------------------------
  if(TBoxPulseApp_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to slicerMacroBuildApplication(): \"${SLICERAPP_UNPARSED_ARGUMENTS}\"")
  endif()

  if(NOT DEFINED TBoxPulseApp_SPLASHSCREEN_ENABLED)
      set(TBoxPulseApp_SPLASHSCREEN_ENABLED TRUE)
  endif()

  #-----------------------------------------------------------------------------------------------------
  #Checks expectede variables
  #-----------------------------------------------------------------------------------------------------
  set(expected_defined_vars
      NAME
      LINUX_ICON_FILE
      WIN_ICON_FILE
      LICENSE_FILE
  )
  if(TBoxPulseApp_SPLASHSCREEN_ENABLED)
      list(APPEND expected_defined_vars
          LAUNCHER_SPLASHSCREEN_FILE)
  endif()

  foreach(var ${expected_defined_vars})
      if(NOT DEFINED TBoxPulseApp_${var})
          message(FATAL_ERROR "${var} is mandatory")
      endif()
  endforeach()

  if(NOT DEFINED TBoxPulseApp_APPLICATION_NAME)
      string(REGEX REPLACE TBoxPulseApp_APPLICATION_NAME ${TBoxPulseApp_NAME})
  endif()

  message("Debug :TBoxPulseApp_APPLICATION_NAME = ${TBoxPulseApp_APPLICATION_NAME}")
  macro(set_app_property_ varname)
      set_property(GLOBAL PROPERTY ${TBoxPulseApp_APPLICATION_NAME}_${varname} ${TBoxPulseApp_${varname}})
      message(STATUS "Setting ${TBoxPulseApp_APPLICATION_NAME} ${varname} to  '${TBoxPulseApp_${varname}}' ")
  endmacro()

  if(TBoxPulseApp_APPLICATION_NAME STREQUAL TBoxPulse_ORGANIZATION_NAME)
      message(TATAL_ERROR "Application name [${TBoxPulseApp_APPLICATION_NAME}] must be different from the orgnization name")
  endif()

  set_app_property_("APPLICATION_NAME")

  macro(set_app_path_var_ varname)
      if(NOT IS_ABSOLUTE ${TBoxPulseApp_${varname}})
          set(TBoxPulseApp_${varname} ${CMAKE_CURRENT_SOURCE_DIR}/${TBoxPulseApp_${varname}})
      endif()

      if(NOT EXISTS "${TBoxPulseApp_${varname}}")
          message(FATAL_ERROR "error : Variable ${varname} set to  ${TBoxPulseApp_${varname}}  corresponds to an nonexistent file. ")
      endif()

      set_app_property_(${varname})
  endmacro()

  if(TBoxPulseApp_SPLASHSCRREEN_ENABLED)
      set_app_path_var_(LUANCHER_SPLASHSCREEN_ENABLED)
  endif()

  set_app_path_var_(LINUX_ICON_FILE)
  set_app_path_var_(WIN_ICON_FILE)
  set_app_path_var_(LISENSE_FILE)
  if(DEFINED TBoxPulseApp_DEFAULT_SETTING_FILE)
      set_app_path_var_(DEFAULT_SETTING_FILE)
  endif()

  #----------------------------------------------------------------------------------------------------
  #Folder
  #----------------------------------------------------------------------------------------------------
  if(NOT DEFINED TBoxPulseApp_FOLDER)
      set(TBoxPulseApp_FOLDER "App-${TBoxPulseApp_APPLICATION_NAME}")
  endif()

  #-----------------------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------------------------
  if(APPLE)

  endif()


  #----------------------------------------------------------------------------------------------------
  #Include dirs
  #----------------------------------------------------------------------------------------------------
  set(include_dirs
      ${CMAKE_CURRENT_SOURCE_DIR}
      ${CMAKE_CURRENT_BINARY_DIR}
      ${TBoxPulseApp_INCLUDE_DIRECTORIES}
  )
  include_directories(include_dir)


  # --------------------------------------------------------------------------
  # Build the executable (Linux-only version)
  # Linux always uses console for both main app and launcher
  # --------------------------------------------------------------------------
  set(TBoxPulse_HAS_CONSOLE_IO_SUPPORT TRUE)  # Main app will attach to terminal
  set(TBoxPulse_HAS_CONSOLE_LAUNCHER TRUE)    # Launcher will attach to terminal

  # No platform-specific options needed for Linux
  set(TBoxPulseAppLib_EXE_OPTIONS)

  # Set target name
  set(tboxpulse_app_target ${TBoxPulseApp_NAME})
  if(DEFINED TBoxPulseApp_TARGET_NAME_VAR)
      set(${TBoxPulseApp_TARGET_NAME_VAR} ${tboxpulse_app_target})
  endif()

  set(executable_name ${TBoxPulseApp_APPLICATION_NAME})
  message(STATUS "Setting Linux executable name to: ${executable_name}${CMAKE_EXECUTABLE_SUFFIX}")

  add_executable(${tboxpulse_app_target}
      Main.cpp)

    # 添加以下代码，确保可执行文件链接基础库和应用程序库
    target_link_libraries(${tboxpulse_app_target}
        ${TBoxPulseApp_TARGET_LIBRARIES}  # 包含 qTBoxPulseAppLib
        qTBoxPulseBaseQTApp               # 显式添加基础库
    )

  set_target_properties(${tboxpulse_app_target} PROPERTIES
      LABELS ${TBoxPulseApp_NAME}
      OUTPUT_NAME ${tboxpulse_app_target}
  )


endmacro()
