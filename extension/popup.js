"use strict";
const RELEASES_URL = 'https://github.com/aoroudjev/GraphicsFlipperExtension/releases/latest';
const badge = document.getElementById('badge');
const badgeText = document.getElementById('badge-text');
const statusLabel = document.getElementById('status-label');
const statusSub = document.getElementById('status-sub');
const toggleBtn = document.getElementById('toggle-btn');
const message = document.getElementById('message');
const installLink = document.getElementById('install-link');
const browser = navigator.userAgent.includes('Edg/') ? 'edge' : 'chrome';
const browserName = browser === 'edge' ? 'Edge' : 'Chrome';
installLink.addEventListener('click', (e) => {
    e.preventDefault();
    chrome.tabs.create({ url: RELEASES_URL });
});
function setStatus(enabled) {
    badge.className = 'badge ' + (enabled ? 'on' : 'off');
    badgeText.textContent = enabled ? 'On' : 'Off';
    statusLabel.textContent = enabled ? 'Enabled' : 'Disabled';
    statusSub.textContent = enabled ? 'GPU acceleration is active' : 'GPU acceleration is off';
    toggleBtn.disabled = false;
    installLink.hidden = true;
    toggleBtn.textContent = enabled ? 'Disable & Restart' : 'Enable & Restart';
}
function setError(msg) {
    badge.className = 'badge loading';
    badgeText.textContent = '—';
    statusLabel.textContent = 'Unavailable';
    statusSub.textContent = 'Companion app not found';
    message.textContent = msg;
    message.className = 'message error';
    installLink.hidden = false;
}
chrome.runtime.sendMessage({ action: 'get_status', browser }, (res) => {
    var _a, _b, _c;
    if (chrome.runtime.lastError || !res || res.status !== 'ok') {
        setError((_b = (_a = chrome.runtime.lastError) === null || _a === void 0 ? void 0 : _a.message) !== null && _b !== void 0 ? _b : 'Could not reach native host');
        return;
    }
    setStatus((_c = res.enabled) !== null && _c !== void 0 ? _c : true);
});
toggleBtn.addEventListener('click', () => {
    toggleBtn.disabled = true;
    message.textContent = '';
    message.className = 'message';
    chrome.runtime.sendMessage({ action: 'toggle', browser }, (res) => {
        var _a, _b;
        if (chrome.runtime.lastError || !res || res.status !== 'ok') {
            setError((_b = (_a = chrome.runtime.lastError) === null || _a === void 0 ? void 0 : _a.message) !== null && _b !== void 0 ? _b : 'Toggle failed');
            toggleBtn.disabled = false;
            return;
        }
        badge.className = 'badge loading';
        badgeText.textContent = '—';
        statusLabel.textContent = 'Restarting\u2026';
        statusSub.textContent = `${browserName} will reopen with your tabs`;
        message.textContent = `${browserName} is restarting, this window will close.`;
    });
});
