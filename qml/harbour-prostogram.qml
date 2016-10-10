import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import harbour.prostogram 1.0

import "pages"
import "components"

import "Storage.js" as Storage
import "Api.js" as API
import "MediaStreamMode.js" as MediaStreamMode
import "Cover.js" as CoverCtl
import "FavManager.js" as FavManager

ApplicationWindow {
    id: app
    property var cachedFeeds : null
    property var cachedFeedsTime : null

    property var refreshCallback : null
    property bool refreshCallbackPending : false

    property var user

    signal coverRefreshButtonPress();


    initialPage: getInitialPage()
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Instagram{
        id: instagram
    }

    NotificationStream{
        id: notifyStream
    }

    function getInitialPage() {
        loadFavTags()
        var username = Storage.get("username");
        var password = Storage.get("password")
        if (username === "" ||  password === "" || username === undefined || password === undefined || username === null || password === null ) {
            return Qt.resolvedUrl("pages/AuthPage.qml")
        } else {
            instagram.setUsername(username);
            instagram.setPassword(password);
            instagram.login(true);
            return Qt.resolvedUrl(Qt.resolvedUrl("pages/StartPage.qml"))
        }
    }

    function refresh(){
       coverRefreshButtonPress();
    }

    function setCoverImage(imageString,username) {
        API.coverImage = imageString
        API.coverUsername = username
    }

    property int streamPreviewColumnCount: 3;
    property int  streamPreviewRowCount : 2;

    property bool  startPageShowPopularFeed : true;
    property bool  feedsShowCaptions : false;
    property bool feedsShowUserDate : true;
    property bool feedsShowUserDateInline : true;


    Component.onCompleted: {
        init();
    }

    function init() {
        streamPreviewColumnCount = Storage.get("streamPreviewColumnCount", 3);
        streamPreviewRowCount = Storage.get("streamPreviewRowCount", 4);
        startPageShowPopularFeed = parseInt(Storage.get("startPageShowPopularFeed", 1)) === 1;
        feedsShowCaptions = parseInt(Storage.get("feedsShowCaptions", 0)) === 1;
        feedsShowUserDate = parseInt(Storage.get("feedsShowUserDate", 1)) === 1;
        feedsShowUserDateInline = parseInt(Storage.get("feedsShowUserDateInline", 1)) === 1;
    }

    function setCover(coverMode, coverData) {
        CoverCtl.nextMode = coverMode
        CoverCtl.nextCoverData = coverData
        CoverCtl.nextChanged = true
    }

    function setCoverRefresh(coverMode, coverData,refreshMode, refreshTag) {
        CoverCtl.refrMode = refreshMode
        CoverCtl.refrTag = refreshTag
        CoverCtl.nextMode = coverMode
        CoverCtl.nextCoverData = coverData
        CoverCtl.nextChanged = true
    }

    function saveFavTags() {
        var favTagsList = FavManager.favTags.join(';')
        Storage.set("favtags", favTagsList)
    }

    function loadFavTags() {
        var favTagsList = Storage.get("favtags", "")
        FavManager.favTags = favTagsList===""|| favTagsList===null  ? [] : favTagsList.split(";")
        FavManager.favTag = Storage.get("favtag", "")
    }


    onApplicationActiveChanged: {
        if (applicationActive === true) {

            if(refreshCallback!==null && refreshCallbackPending) {
                refreshCallbackPending = false
                refreshCallback()
            }
        }
    }

}
