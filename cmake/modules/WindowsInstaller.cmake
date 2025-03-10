set(WINDOWS_INSTALL_FILES "veyon-${VEYON_WINDOWS_ARCH}-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_BUILD}")

set(DLLDIR "${MINGW_PREFIX}/bin")
set(DLLDIR_LIB "${MINGW_PREFIX}/lib")
string(REGEX MATCH "^[^.]+" GCC_VERSION_MAJOR ${CMAKE_CXX_COMPILER_VERSION})
set(DLLDIR_GCC "/usr/lib/gcc/${MINGW_TARGET}/${GCC_VERSION_MAJOR}-posix")
if(VEYON_BUILD_WIN64)
	set(DLL_GCC "libgcc_s_seh-1.dll")
	set(DLL_DDENGINE "ddengine64.dll")
else()
	set(DLL_GCC "libgcc_s_dw2-1.dll")
	set(DLL_DDENGINE "ddengine.dll")
endif()

add_custom_target(windows-binaries
	COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config $<CONFIGURATION>
	COMMAND rm -rf ${WINDOWS_INSTALL_FILES}*
	COMMAND mkdir -p ${WINDOWS_INSTALL_FILES}/interception
	COMMAND cp ${CMAKE_SOURCE_DIR}/3rdparty/interception/* ${WINDOWS_INSTALL_FILES}/interception
	COMMAND cp ${CMAKE_SOURCE_DIR}/3rdparty/ddengine/${DLL_DDENGINE} ${WINDOWS_INSTALL_FILES}
	COMMAND cp core/veyon-core.dll ${WINDOWS_INSTALL_FILES}
	COMMAND find . -mindepth 2 -name 'veyon-*.exe' -exec cp '{}' ${WINDOWS_INSTALL_FILES}/ '\;'
	COMMAND mkdir -p ${WINDOWS_INSTALL_FILES}/plugins
	COMMAND find plugins/ -name '*.dll' -exec cp '{}' ${WINDOWS_INSTALL_FILES}/plugins/ '\;'
	COMMAND mv ${WINDOWS_INSTALL_FILES}/plugins/lib*.dll ${WINDOWS_INSTALL_FILES}
	COMMAND mv ${WINDOWS_INSTALL_FILES}/plugins/vnchooks.dll ${WINDOWS_INSTALL_FILES}
	COMMAND mkdir -p ${WINDOWS_INSTALL_FILES}/translations
	COMMAND cp translations/*qm ${WINDOWS_INSTALL_FILES}/translations/
	COMMAND cp ${DLLDIR}/libjpeg-62.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/libpng16-16.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/libcrypto-3*.dll ${DLLDIR}/libssl-3*.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/libqca-qt6.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/libsasl2-3.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/libldap.dll ${DLLDIR}/liblber.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/interception.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/liblzo2-2.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR}/libvncclient.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR_LIB}/zlib1.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR_LIB}/libwinpthread-1.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR_GCC}/libstdc++-6.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR_GCC}/libssp-0.dll ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${DLLDIR_GCC}/${DLL_GCC} ${WINDOWS_INSTALL_FILES}
	COMMAND mkdir -p ${WINDOWS_INSTALL_FILES}/crypto
	COMMAND cp ${DLLDIR_LIB}/qca-qt6/crypto/libqca-ossl.dll ${WINDOWS_INSTALL_FILES}/crypto
	COMMAND cp ${DLLDIR}/Qt6Core.dll
				${DLLDIR}/Qt6Core5Compat.dll
				${DLLDIR}/Qt6Gui.dll
				${DLLDIR}/Qt6Widgets.dll
				${DLLDIR}/Qt6Network.dll
				${DLLDIR}/Qt6Concurrent.dll
				${DLLDIR}/Qt6OpenGL.dll
				${DLLDIR}/Qt6Qml.dll
				${DLLDIR}/Qt6QmlModels.dll
				${DLLDIR}/Qt6Quick.dll
				${DLLDIR}/Qt6QuickControls2.dll
				${DLLDIR}/Qt6QuickTemplates2.dll
			${WINDOWS_INSTALL_FILES}
	COMMAND mkdir -p ${WINDOWS_INSTALL_FILES}/imageformats
	COMMAND cp ${MINGW_PREFIX}/plugins/imageformats/qjpeg.dll ${WINDOWS_INSTALL_FILES}/imageformats
	COMMAND mkdir -p ${WINDOWS_INSTALL_FILES}/platforms
	COMMAND cp ${MINGW_PREFIX}/plugins/platforms/qwindows.dll ${WINDOWS_INSTALL_FILES}/platforms
	COMMAND mkdir -p ${WINDOWS_INSTALL_FILES}/styles
	COMMAND cp ${MINGW_PREFIX}/plugins/styles/*.dll ${WINDOWS_INSTALL_FILES}/styles
	COMMAND ${MINGW_TOOL_PREFIX}strip ${WINDOWS_INSTALL_FILES}/*.dll ${WINDOWS_INSTALL_FILES}/*.exe ${WINDOWS_INSTALL_FILES}/plugins/*.dll ${WINDOWS_INSTALL_FILES}/platforms/*.dll ${WINDOWS_INSTALL_FILES}/styles/*.dll ${WINDOWS_INSTALL_FILES}/crypto/*.dll
	COMMAND cp ${CMAKE_SOURCE_DIR}/COPYING ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${CMAKE_SOURCE_DIR}/COPYING ${WINDOWS_INSTALL_FILES}/LICENSE.TXT
	COMMAND cp ${CMAKE_SOURCE_DIR}/README.md ${WINDOWS_INSTALL_FILES}/README.TXT
	COMMAND todos ${WINDOWS_INSTALL_FILES}/*.TXT
	COMMAND cp -ra ${CMAKE_SOURCE_DIR}/nsis ${WINDOWS_INSTALL_FILES}
	COMMAND cp ${CMAKE_BINARY_DIR}/nsis/veyon.nsi ${WINDOWS_INSTALL_FILES}
	COMMAND find ${WINDOWS_INSTALL_FILES} -ls
)

add_custom_target(create-windows-installer
	COMMAND makensis ${WINDOWS_INSTALL_FILES}/veyon.nsi
	COMMAND mv ${WINDOWS_INSTALL_FILES}/veyon-*setup.exe .
	COMMAND rm -rf ${WINDOWS_INSTALL_FILES}
	DEPENDS windows-binaries
)

add_custom_target(prepare-dev-nsi
	COMMAND sed -i ${WINDOWS_INSTALL_FILES}/veyon.nsi -e "s,/SOLID lzma,zlib,g"
	DEPENDS windows-binaries)

add_custom_target(dev-nsi
	DEPENDS prepare-dev-nsi create-windows-installer
)

