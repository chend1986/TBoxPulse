    project(qTBoxPulseBaseQTApp)

    #-------------------------------------------------------------------------
    #See CMake/TBoxPulseMacroBuildBaseQTLibrary
    #-------------------------------------------------------------------------
    set(KIT_export_directive "Q_TBOX_BASE_QTAPP_EXPORT")

    #source file
    set(KIT_SRCS
       qTBoxPulseMainWindow.cpp
       qTBoxPulseMainWindow.h)

    #Headers that should run through moc
    set(KIT_MOC_SRCS
       qTBoxPulseMainWindow.h)

    #UI files
    set(KIT_UI_SRCS
       Resources/qTBoxPulseMainWindow.ui)

    #Resources
    set(KIT_resources)

    #Add directories to include
    #set(KIT_include_directories
    #  ${CMAKE_CURRENT_SOURCE_DIR}
    #  ${CMAKE_CURRENT_BINARY_DIR}
    #)

    TBoxMacroBuildBaseQtLibrary(
        NAME ${PROJECT_NAME}
        EXPORT_DIRECTIVE ${KIT_export_directive}
        #INCLUDE_DIRECTORIES ${KIT_include_directories}
        SRCS ${KIT_SRCS}
        MOC_SRCS ${KIT_MOC_SRCS}
        UI_SRCS ${KIT_UI_SRCS}
    )

    if(BUILD_TESTING)
        add_subdirectory(Testing)
    endif()


