project(TBoxPulseApp)

include(TBoxMacroBuildApplication)
include(TBoxReadApplicationProperties)

# --------------------------------------------------------------------------
# Properties
# --------------------------------------------------------------------------
message("Debug: Read appplication properties file")
TBoxReadApplicationProperties()


# --------------------------------------------------------------------------
# Folder
# --------------------------------------------------------------------------
set(${PROJECT_NAME}_FOLDER "App-${TBoxPulseApp_APPLICATION_NAME}")

# --------------------------------------------------------------------------
# Application library
# --------------------------------------------------------------------------
set(APPLIB_NAME "q${PROJECT_NAME}Lib")
message("Debug : APPLIB_NAME = ${APPLIB_NAME}")

set(APPLIB_SRCS
  qTBoxPulseAppMainWindow.cpp
  qTBoxPulseAppMainWindow.h
  qTBoxPulseAppMainWindowImpl.h
  )

set(APPLIB_MOC_SRCS
  qTBoxPulseAppMainWindow.h
  )

set(APPLIB_UI_SRCS
  )

set(APPLIB_RESOURCES
  Resources/qTBoxPulseApp.qrc
  )

message(STATUS "-------------------------------------------------------------------------------")
message("Current project name: ${PROJECT_NAME}")
message("Properties file path: ${TBoxPulse_APPLICATIONS_DIR}/${PROJECT_NAME}/TBoxPulse-application-properties.cmake")

TBoxMacroBuildAppLibrary(
    NAME ${APPLIB_NAME}
    APPLICATION_NAME ${TBoxPulseApp_APPLICATION_NAME}
    DESCRIPTION_SUMMARY ${TBoxPulseApp_DESCRIPTION_SUMMARY}
    DESCRIPTION_FILE ${TBoxPulseApp_DESCRIPTION_FILE}
    EXPORT_DIRECTIVE "QT_TBoxPulseApp_APP_EXPORT"
    FOLDER ${${PROJECT_NAME}_FOLDE}
    SRCS ${APPLIB_SRCS}
    MOC_SRCS ${APPLIB_MOC_SRCS}
    UI_SRCS ${APPLIB_UI_SRCS}
    RESOURCES ${APPLIB_RESOURCES}
)


if(NOT DEFINED TBoxPulse_MAIN_PROJECT)
  message("Debug : TBoxPulse_MAIN_PROJECT = ${TBoxPulse_MAIN_PROJECT}")
endif()

# Configure launcher only for the main application
set(extra_args)
if(${PROJECT_NAME} STREQUAL ${TBoxPulse_MAIN_PROJECT})
  set(extra_args CONFIGURE_LAUNCHER)
endif()

set(APP_SRCS
  Main.cxx
  )

message("==================================================================================")
message("Debug : TBoxPulseApp_LINUX_ICON_FILE = ${TBoxPulseApp_LINUX_ICON_FILE}")
message("Debug : PROJECT_NAME = ${PROJECT_NAME}")
message("Debug : TBoxPulseApp_WIN_ICON_FILE = ${TBoxPulseApp_WIN_ICON_FILE}")
message("Debug : TBoxPulseApp_LICENCE_FILE = ${TBoxPulseApp_LICENSE_FILE}")
message("Debug : TBoxPulseApp_LUANCHER_SPLASHSCREEN_FILE = ${TBoxPulseApp_LAUNCHER_SPLASHSCREEN_FILE}")

TBoxMacroBuildApplication(
  NAME ${PROJECT_NAME}
  APPLICATION_NAME ${${PROJECT_NAME}_APPLICATION_NAME}
  LAUNCHER_SPLASHSCREEN_FILE ${TBoxPulseApp_LAUNCHER_SPLASHSCREEN_FILE}
  LINUX_ICON_FILE ${TBoxPulseApp_LINUX_ICON_FILE}
  WIN_ICON_FILE ${TBoxPulseApp_WIN_ICON_FILE}
  LICENSE_FILE ${TBoxPulseApp_LICENSE_FILE}
  FOLDER ${${PROJECT_NAME}_FOLDER}
  SRCS ${APP_SRCS}
  TARGET_LIBRARIES ${APPLIB_NAME}
  TARGET_NAME_VAR "APP_TARGET_NAME"
  ${extra_args}
  )







