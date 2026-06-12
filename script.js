const accItems = Array.from(document.querySelectorAll('.acc-item'));

accItems.forEach((item) => {
  item.addEventListener('click', () => {
    if (item.classList.contains('is-active')) return;
    accItems.forEach((other) => {
      const active = other === item;
      other.classList.toggle('is-active', active);
      other.setAttribute('aria-expanded', String(active));
    });
  });
});

const nav = document.getElementById('nav');
const toTop = document.getElementById('toTop');

function onScroll() {
  const scrolled = window.scrollY > 24;
  nav.classList.toggle('scrolled', scrolled);
  toTop.classList.toggle('show', window.scrollY > 600);
}

window.addEventListener('scroll', onScroll, { passive: true });
onScroll();

toTop.addEventListener('click', () => {
  window.scrollTo({ top: 0, behavior: 'smooth' });
});

const burger = document.getElementById('burger');
const menu = document.getElementById('menu');

burger.addEventListener('click', () => {
  const open = menu.classList.toggle('open');
  burger.setAttribute('aria-expanded', String(open));
});

menu.addEventListener('click', (event) => {
  if (event.target.closest('a')) {
    menu.classList.remove('open');
    burger.setAttribute('aria-expanded', 'false');
  }
});
