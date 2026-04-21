interface NativeResponse {
  status: 'ok' | 'error';
  enabled?: boolean;
  restarting?: boolean;
  message?: string;
}

type BrowserType = 'edge' | 'chrome';

const badge       = document.getElementById('badge') as HTMLElement;
const badgeText   = document.getElementById('badge-text') as HTMLElement;
const statusLabel = document.getElementById('status-label') as HTMLElement;
const statusSub   = document.getElementById('status-sub') as HTMLElement;
const toggleBtn   = document.getElementById('toggle-btn') as HTMLButtonElement;
const message     = document.getElementById('message') as HTMLElement;

const browser: BrowserType = navigator.userAgent.includes('Edg/') ? 'edge' : 'chrome';
const browserName = browser === 'edge' ? 'Edge' : 'Chrome';

function setStatus(enabled: boolean): void {
  badge.className         = 'badge ' + (enabled ? 'on' : 'off');
  badgeText.textContent   = enabled ? 'On' : 'Off';
  statusLabel.textContent = enabled ? 'Enabled' : 'Disabled';
  statusSub.textContent   = enabled ? 'GPU acceleration is active' : 'GPU acceleration is off';
  toggleBtn.disabled      = false;
  toggleBtn.textContent   = enabled ? 'Disable & Restart' : 'Enable & Restart';
}

function setError(msg: string): void {
  badge.className         = 'badge loading';
  badgeText.textContent   = '—';
  statusLabel.textContent = 'Unavailable';
  statusSub.textContent   = 'Is the companion app installed?';
  message.textContent     = msg;
  message.className       = 'message error';
}

chrome.runtime.sendMessage({ action: 'get_status', browser }, (res: NativeResponse) => {
  if (chrome.runtime.lastError || !res || res.status !== 'ok') {
    setError(chrome.runtime.lastError?.message ?? 'Could not reach native host');
    return;
  }
  setStatus(res.enabled ?? true);
});

toggleBtn.addEventListener('click', () => {
  toggleBtn.disabled  = true;
  message.textContent = '';
  message.className   = 'message';

  chrome.runtime.sendMessage({ action: 'toggle', browser }, (res: NativeResponse) => {
    if (chrome.runtime.lastError || !res || res.status !== 'ok') {
      setError(chrome.runtime.lastError?.message ?? 'Toggle failed');
      toggleBtn.disabled = false;
      return;
    }
    badge.className         = 'badge loading';
    badgeText.textContent   = '—';
    statusLabel.textContent = 'Restarting\u2026';
    statusSub.textContent   = `${browserName} will reopen with your tabs`;
    message.textContent     = `${browserName} is restarting, this window will close.`;
  });
});
