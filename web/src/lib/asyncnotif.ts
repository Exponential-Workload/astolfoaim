// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck
const ff = (typeof (navigator) === 'undefined' || !navigator.userAgent.toLowerCase().includes('firefox')) ? (_ff: string, chrome = '') => chrome : (ff: string) => ff
const ourBg = ff('#24273aaa', '#24273add');
const ourExtraStyles = 'color: #bdbebe;';
const buttonStyles = `background: ${ourBg};${ff('backdrop-filter: blur(16px);')} padding: 8px 8px; border: none; color: #fff;`;
const containerStyle = `position:fixed;top:0;left:0;width:100vw;height:100vh;display:flex;align-items:center;justify-content:center;background:${ourBg};${ff('backdrop-filter:blur(8px);')}text-align:center;transition:${ff('1', '0')}s;opacity:1;animation-name:transitionInContainer;animation-duration: ${ff('0.5', '0')}s;animation-direction: normal;animation-iteration-count: 1;animation-timing-function: ease-in-out;${ourExtraStyles}`;

const getResolveDestroy = (container, res) => (state) => {
  container.querySelector('#yeeeeee').style.pointerEvents = 'none';
  container.querySelector('#yeeeeee').style.opacity = 0;
  container.querySelector('#yeeeeee').style.background = '#23252700';
  container.querySelector('#yeeeeee').style.backdropFilter = 'none';
  setTimeout(() => container.remove(), 1500);
  res(state);
};

if (typeof document !== 'undefined') {
  const leStyle = document.createElement('style');
  leStyle.setAttribute('data-style', 'settingsthing');
  leStyle.innerHTML = `@keyframes transitionInContainer {
  from {
    opacity: 0;
    background: #23252700;
    ${ff('backdrop-filter: blur(0px);')}
  }
  to {
    opacity: 1;
    background: ${ourBg};
    ${ff('backdrop-filter: blur(8px);')}
  }
}
#yeeeeee #outputtedValue:focus,
#yeeeeee #outputtedValue:active {
  outline: none;
}
`;
  document.head.appendChild(leStyle);
}

export const asyncButtons = <T extends string>(text: string, buttons: T[] = ['OK']): Promise<T> => {
  if (typeof text === 'undefined') throw new Error('no text specified')
  const container = document.createElement('div');
  container.innerHTML = `<div style="${containerStyle}" id="yeeeeee">
<div>
  <p id="status" style="${ourExtraStyles}">${text}</p>
  ${buttons.map(btn => `<button data-confirmation="${btn}" style="${buttonStyles}">${btn}</button>`).join(' ')}
</div>
</div>`;
  let resolve;
  const promise = new Promise(res => {
    resolve = getResolveDestroy(container, res);
  });
  container.querySelectorAll('[data-confirmation]').forEach(v => v.addEventListener('click', () => resolve(v.getAttribute('data-confirmation'))));
  document.body.appendChild(container);
  return promise;
};

export const asyncConfirm = async (text: string) => (await asyncButtons(text, ['Yes', 'No'])) === 'Yes'

export const asyncAlert = (text: string, btnText = 'OK'): Promise<void> => {
  if (typeof text === 'undefined') throw new Error('no text specified')
  const container = document.createElement('div');
  container.innerHTML = `<div style="${containerStyle}" id="yeeeeee">
<div>
  <p id="status" style="${ourExtraStyles}">${text}</p>
  <button id="ok" style="${buttonStyles}">${btnText ?? 'OK'}</button>
</div>
</div>`;
  let resolve;
  const promise = new Promise(res => {
    resolve = getResolveDestroy(container, res);
  });
  container.querySelector('#ok').addEventListener('click', () => resolve(void 0));
  document.body.appendChild(container);
  return promise;
};

type AsyncPromptFunc = ((text: string, defaultValue?: string, btnText?: string, cancellable?: false) => Promise<string>) & ((text: string, defaultValue?: string, btnText?: string, cancellable: true | string) => Promise<string | void>)
export const asyncPrompt: AsyncPromptFunc = (text, defaultValue = '', btnText = 'OK', cancellable = false) => {
  const container = document.createElement('div');
  container.innerHTML = `<div style="${containerStyle}" id="yeeeeee">
<div>
  <p id="status" style="${ourExtraStyles}">${text}</p>
  <input type="text" id="outputtedValue" value="${defaultValue}" style="margin-bottom:4px;${buttonStyles}" />
  <br/>
  <button id="ok" style="${buttonStyles}">${btnText ?? 'OK'}</button>${cancellable ? ` <button id="cancel" style="${buttonStyles}">${cancellable === true ? 'Cancel' : cancellable}</button>` : ''}
</div>
</div>`;
  let resolve;
  const promise = new Promise(res => {
    resolve = getResolveDestroy(container, res);
  });
  const ov = container.querySelector('#outputtedValue') as HTMLInputElement
  ov.style.borderBottom = '#fff 1px solid'
  container.querySelector('#ok').addEventListener('click', () => {
    const val = ov.value as string
    if (!val || val.length === 0) {
      ov.style.borderBottom = '#f00 1px solid'
      return;
    }
    resolve(val)
  });
  const c = container.querySelector('#cancel');
  if (c)
    c.addEventListener('click', () => resolve(void 0));
  document.body.appendChild(container);
  return promise;
};

// for longer-term alerts
type DestroyFunc = () => void;
type UpdateFunc = (text: string) => DestroyFunc
export const createStateNotif = (): UpdateFunc => {
  const container = document.createElement('div');
  container.innerHTML = `<div style="${containerStyle}" id="yeeeeee">
<p id="status" style="${ourExtraStyles}"></p>
</div>`;
  let isParented = false;
  const destroy = () => {
    container.querySelector('#yeeeeee').style.pointerEvents = 'none';
    container.querySelector('#yeeeeee').style.opacity = 0;
    container.querySelector('#yeeeeee').style.background = (ourBg.length === 4 || ourBg.length === 5) ? `${ourBg.substring(0, 4)}0` : `${ourBg.substring(0, 7)}00`;
    container.querySelector('#yeeeeee').style.backdropFilter = 'none';
    setTimeout(() => container.remove(), 1500);
  };
  return (text) => {
    if (!isParented)
      document.body.appendChild(container);
    isParented = true;
    container.querySelector('#status').innerText = text;
    if (text === 'Done!')
      setTimeout(destroy, 500);
    return destroy;
  };
};
