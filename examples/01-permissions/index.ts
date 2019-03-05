import { h, attrs, props, create } from './sdom';


function render() {
  return h.div([
    h.h2('Permission management'),
    h.p('Lorem ipsum'),
  ]);
}

const container = document.createElement('div');
document.body.appendChild(container);
const sdom = render();
let el = create<{}>(sdom, {});
container.appendChild(el);
