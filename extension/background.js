"use strict";
const HOST = 'com.gpuflip.toggle';
chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
    chrome.runtime.sendNativeMessage(HOST, { action: msg.action, browser: msg.browser }, (response) => {
        if (chrome.runtime.lastError) {
            sendResponse({ status: 'error', message: chrome.runtime.lastError.message });
        }
        else {
            sendResponse(response);
        }
    });
    return true;
});
