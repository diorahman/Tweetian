/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

ContextMenu {
    id: root

    property string screenName
    property string id
    property string dmText

    property bool __isClosing: false

    platformInverted: settings.invertedTheme

    MenuLayout {
        id: menuLayout
        MenuItemWithIcon {
            iconSource: "image://theme/qtg_toolbar_copy" + (platformInverted ? "_inverse" : "" )
            text: qsTr("Copy DM")
            onClicked: {
                // TODO: Remove html for links
                QMLUtils.copyToClipboard("@" + screenName + ": " + dmText)
                infoBanner.showText(qsTr("DM copied to clipboard"))
            }
        }
        MenuItemWithIcon {
            iconSource: platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
            text: qsTr("Delete")
            onClicked: internal.createDeleteDMDialog(id)
        }
        MenuItemWithIcon {
            iconSource: platformInverted ? "../Image/contacts_inverse.svg" : "../Image/contacts.svg"
            text: qsTr("%1 Profile").arg("<font color=\"LightSeaGreen\">@" + screenName + "</font>")
            visible: screenName != ""
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: screenName})
        }
        Repeater {
            id: linksRepeater

            MenuItemWithIcon {
                width: menuLayout.width
                iconSource: platformInverted ? "../Image/internet_inverse.svg" : "../Image/internet.svg"
                text: modelData.substring(modelData.indexOf('://') + 3)
                onClicked: dialog.createOpenLinkDialog(modelData)
            }
        }
    }

    Component.onCompleted: {
        var linksArray = dmText.match(/href="http[^"]+"/g)
        if (linksArray != null) {
            for (var i=0; i < linksArray.length; i++) {
                linksArray[i] = linksArray[i].substring(6, linksArray[i].length - 1)
            }
            linksRepeater.model = linksArray
        }
        open()
    }

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}

