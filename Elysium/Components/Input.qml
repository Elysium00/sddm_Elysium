import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0

Column {
    id: inputContainer
    Layout.fillWidth: true
    spacing: 10

    property Control exposeSession: sessionSelect.exposeSession
    property bool failed: false

    // --- PROPIEDADES PARA LOGIN ---
    property alias user: selectUser.currentText

    // Función para abrir el selector de usuario desde la foto
    function showUserList() {
        selectUser.popup.open()
    }

    Item {
        height: 10
        width: parent.width
    }

    // --- SELECTOR DE USUARIO (ComboBox con Iconos) ---
    Item {
        id: usernameField
        // El selector ahora es visible solo cuando se abre, para no empujar los demás elementos
        height: selectUser.popup.visible ? root.font.pointSize * 2 : 0
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        ComboBox {
            id: selectUser
            anchors.fill: parent
            opacity: popup.visible ? 1 : 0 // Solo se ve si está abierto
            focus: true

            property var popkey: config.ForceRightToLeft == "true" ? Qt.Key_Right : Qt.Key_Left

            Keys.onPressed: {
                if (event.key == Qt.Key_Down && !popup.opened)
                    password.forceActiveFocus();
                if ((event.key == Qt.Key_Up || event.key == popkey) && !popup.opened)
                    popup.open();
            }

            model: userModel
            currentIndex: model.lastIndex
            textRole: "name"

            // --- DELEGATE CON ICONO DE USUARIO ---
            delegate: ItemDelegate {
                width: parent.width
                height: root.font.pointSize * 3.5

                contentItem: Row {
                    spacing: 15
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10

                    Image {
                        id: userIcon
                        source: model.icon || "../Assets/user.svg" // Fallback si no hay icono
                        width: root.font.pointSize * 2.2
                        height: width
                        fillMode: Image.PreserveAspectCrop
                        anchors.verticalCenter: parent.verticalCenter

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: userIcon.width
                                height: userIcon.height
                                radius: width / 2
                            }
                        }
                    }

                    Text {
                        text: model.name
                        font.pointSize: root.font.pointSize * 0.9
                        font.capitalization: Font.Capitalize
                        color: selectUser.highlightedIndex === index ? "white" : root.palette.text
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                background: Rectangle {
                    color: selectUser.highlightedIndex === index ? root.palette.highlight : "transparent"
                    radius: config.RoundCorners / 2
                }
            }

            popup: Popup {
                y: parent.height + 5
                x: 0
                width: parent.width
                implicitHeight: contentItem.implicitHeight
                padding: 5

                background: Rectangle {
                    radius: config.RoundCorners / 2
                    color: config.BackgroundColor || root.palette.window
                    border.color: root.palette.highlight
                    border.width: 1
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: Math.min(contentHeight, 300)
                    model: selectUser.delegateModel
                    currentIndex: selectUser.highlightedIndex
                }
            }

            background: Rectangle { color: "transparent" } // Fondo invisible para el ComboBox base
        }
    }

    // --- CAMPO DE CONTRASEÑA ---
    Item {
        id: passwordField
        height: root.font.pointSize * 4
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: password
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            focus: true
            selectByMouse: true
            echoMode: revealSecret.checked ? TextInput.Normal : TextInput.Password
            placeholderText: config.TranslatePlaceholderPassword || textConstants.password
            horizontalAlignment: TextInput.AlignHCenter
            passwordCharacter: "•"
            color: root.palette.text
            renderType: Text.QtRendering

            background: Rectangle {
                color: "transparent"
                border.color: parent.activeFocus ? root.palette.highlight : "#44ffffff"
                border.width: parent.activeFocus ? 2 : 1
                radius: config.RoundCorners || 5
            }
            onAccepted: loginButton.clicked()
        }
    }

    // --- CHECKBOX MOSTRAR CONTRASEÑA ---
    Item {
        id: secretCheckBox
        height: root.font.pointSize * 3
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        CheckBox {
            id: revealSecret
            anchors.centerIn: parent
            hoverEnabled: true

            indicator: Rectangle {
                id: indicatorRect
                implicitHeight: root.font.pointSize
                implicitWidth: root.font.pointSize
                x: revealSecret.leftPadding
                y: parent.height / 2.5 - height / 2
                color: "transparent"
                border.color: root.palette.text
                border.width: revealSecret.activeFocus ? 2 : 1
                radius: 3

                Rectangle {
                    width: parent.width - 6
                    height: parent.height - 6
                    anchors.centerIn: parent
                    color: root.palette.highlight
                    radius: 2
                    visible: revealSecret.checked
                }
            }

            contentItem: Text {
                text: config.TranslateShowPassword || "Show Password"
                font.pointSize: root.font.pointSize * 0.8
                color: root.palette.text
                verticalAlignment: Text.AlignVCenter
                leftPadding: indicatorRect.width + 10
            }

            background: Item { }
        }
    }

    // --- MENSAJE DE ERROR ---
    Item {
        height: root.font.pointSize * 1.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: errorMessage
            width: parent.width
            text: failed ? "¡Login Fallido!" : ""
            horizontalAlignment: Text.AlignHCenter
            color: "#ff4444"
            opacity: failed ? 1 : 0
            font.bold: true

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    // --- BOTÓN LOGIN ---
    Item {
        id: login
        height: root.font.pointSize * 4
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            id: loginButton
            anchors.centerIn: parent
            width: parent.width
            height: root.font.pointSize * 3
            text: config.TranslateLogin || textConstants.login
            enabled: password.text != ""

            contentItem: Text {
                text: loginButton.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: loginButton.enabled ? root.palette.highlight : "#22ffffff"
                radius: config.RoundCorners || 5
                opacity: loginButton.pressed ? 0.8 : 1.0
            }

            onClicked: sddm.login(selectUser.currentText, password.text, sessionSelect.selectedSession)
        }
    }

    // Selector de Sesión (debajo del login por ahora)
    SessionButton {
        id: sessionSelect
        loginButtonWidth: loginButton.width
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Connections {
        target: sddm
        onLoginFailed: {
            failed = true
            resetError.start()
        }
    }

    Timer {
        id: resetError
        interval: 3000
        onTriggered: failed = false
    }
}
