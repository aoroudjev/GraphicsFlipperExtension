const HOST = 'com.gpuflip.toggle';

interface PopupMessage {
  action: 'get_status' | 'toggle';
  browser: 'edge' | 'chrome';
}

chrome.runtime.onMessage.addListener(
  (msg: PopupMessage, _sender: chrome.runtime.MessageSender, sendResponse: (r: unknown) => void) => {
    chrome.runtime.sendNativeMessage(
      HOST,
      { action: msg.action, browser: msg.browser },
      (response: unknown) => {
        if (chrome.runtime.lastError) {
          sendResponse({ status: 'error', message: chrome.runtime.lastError.message });
        } else {
          sendResponse(response);
        }
      }
    );
    return true;
  }
);
