import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import SddmComponents 2.0 as SDDM

ColumnLayout {
    id: formContainer
    SDDM.TextConstants { id: textConstants }

    property int p: config.ScreenPadding
    property string a: config.FormPosition
    property alias systemButtonVisibility: systemButtons.visible
    property alias clockVisibility: clock.visible
    property bool virtualKeyboardActive

    // 1. RELOJ
    Clock {
        id: clock
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        Layout.preferredHeight: root.height / 8
        Layout.leftMargin: p != "0" ? a == "left" ? -p : a == "right" ? p : 0 : 0
        Layout.topMargin: root.height / 6
    }

    // --- 2. BLOQUE DE PERFIL INTERACTIVO ---
    Column {
        id: userProfileBlock
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20
        Layout.bottomMargin: 10
        Layout.leftMargin: p != "0" ? a == "left" ? -p : a == "right" ? p : 0 : 0
        spacing: 12

        // Contenedor del Icono con clic
        Item {
            id: userIconContainer
            width: 150
            height: 150
            anchors.horizontalCenter: parent.horizontalCenter

	Image {
    id: faceIcon
    anchors.fill: parent
    // Usamos la propiedad 'icon' del modelo de usuarios de SDDM si está disponible
    // Si no, intentamos la ruta manual corregida.
    source: userModel.lastUser.icon || "file:///usr/share/sddm/faces/.face.icon"
    fillMode: Image.PreserveAspectCrop
    mipmap: true

    onStatusChanged: {
        // Si la imagen falla (no existe .face.icon), carga tu PNG local
        if (status === Image.Error) {
            console.log("Error cargando icono, usando backup...")
            source = "../Assets/User.svg"
        }
    }

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: userIconContainer.width
            height: userIconContainer.height
            radius: width / 2
        }
    }
}

            // Borde que reacciona al pasar el mouse
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.color: profileClickArea.containsMouse ? root.palette.highlight : "white"
                border.width: profileClickArea.containsMouse ? 3 : 1
                opacity: 0.6
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            // AREA DE CLIC: Al tocar el perfil, abre la lista de usuarios
            MouseArea {
                id: profileClickArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: input.showUserList() // Llama a la función en Input.qml
            }
        }

        // NOMBRE DE USUARIO ABAJO
        Text {
            id: userNameDisplay
            text: input.user
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 28
            font.bold: true
            color: "white"
            style: Text.DropShadow
            styleColor: "#80000000"
        }
    }

    // 3. CAMPOS DE ENTRADA (Input.qml)
    Input {
        id: input
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredHeight: root.height / 4
        Layout.leftMargin: p != "0" ? a == "left" ? -p : a == "right" ? p : 0 : 0
        Layout.topMargin: 10

        // Esta propiedad le dice al Input que oculte el nombre dentro del cuadro
        // para que solo se vea en el texto grande que pusimos arriba.
    }

    Item { Layout.fillHeight: true }

    SystemButtons {
        id: systemButtons
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        Layout.preferredHeight: root.height / 8
        Layout.maximumHeight: root.height / 6
        Layout.bottomMargin: 20
        Layout.leftMargin: p != "0" ? a == "left" ? -p : a == "right" ? p : 0 : 0
        exposedSession: input.exposeSession
    }
}
