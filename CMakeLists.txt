cmake_minimum_required(VERSION 3.9)
project(app)

set(VERSION "0.0.0-devlocal" CACHE STRING "application version")
message(STATUS "application: ${VERSION}")

set(CMAKE_INSTALL_BINDIR "usr/bin" CACHE STRING "" FORCE)
set(CMAKE_INSTALL_LIBDIR "usr/lib" CACHE STRING "" FORCE)
set(CMAKE_INSTALL_PREFIX "/" CACHE STRING "" FORCE)

set(BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR/app}")

add_custom_target(sync
    COMMENT "sync / application code to build directory"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${BUILD_DIR}"
    COMMAND rsync -ravp --perms --times --delete --whole-file
        "${CMAKE_CURRENT_SOURCE_DIR}/src" "${BUILD_DIR}"
    COMMAND rsync -ravp --perms --times --delete --whole-file
        "${CMAKE_CURRENT_SOURCE_DIR}/package.json" "${BUILD_DIR}/"
    COMMAND rsync -ravp --perms --times --delete --whole-file
        "${CMAKE_CURRENT_SOURCE_DIR}/.eslintrc" "${BUILD_DIR}/"
)


add_custom_target(app
    COMMENT "app / create application"
    WORKING_DIRECTORY "${BUILD_DIR}"
    DEPENDS sync
)

file(MAKE_DIRECTORY "${BUILD_DIR}/bin")
configure_file("usr-bin.cmake" "${BUILD_DIR}/bin/start-app" @ONLY)

install(
    FILES "${BUILD_DIR}/bin/start-app"
    DESTINATION "${CMAKE_INSTALL_BINDIR}/"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    COMPONENT app
)

install(
    DIRECTORY "${BUILD_DIR}"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/app/${VERSION}"
    FILE_PERMISSIONS OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ
    DIRECTORY_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    COMPONENT app
)

