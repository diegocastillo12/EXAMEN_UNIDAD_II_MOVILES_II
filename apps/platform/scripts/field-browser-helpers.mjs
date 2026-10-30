// Exercise the same public keyboard/click interface as a user; no Vue state mutation.
export async function chooseField(page, label, option) {
  await page.getByRole('combobox', { name: label, exact: true }).click();
  await page.getByRole('listbox', { name: label, exact: true }).getByRole('option', { name: option, exact: true }).click();
  await page.getByRole('listbox', { name: label, exact: true }).waitFor({ state: 'hidden' });
}
export async function chooseDate(page, label, value) {
  await page.getByRole('button', { name: label, exact: true }).click();
  const dialog = page.getByRole('dialog', { name: label, exact: true });
  const [year,month,day] = value.split('-').map(Number);
  const months = Array.from({ length: 12 }, (_, i) => new Date(2000,i,1).toLocaleDateString('es-PE', {month:'long'}).toLowerCase());
  for (let i=0;i<1200;i++) {
    const title = (await dialog.locator('.sader-calendar-header>span').innerText()).toLowerCase();
    const currentYear = Number(title.match(/\d{4}/)[0]);
    const currentMonth = months.findIndex(m => title.startsWith(m));
    const delta = (year-currentYear)*12+month-1-currentMonth;
    if (!delta) break;
    await dialog.getByRole('button', {name:delta < 0 ? 'Mes anterior' : 'Mes siguiente'}).click();
    await page.waitForFunction(([el,previous]) => el.textContent.toLowerCase() !== previous, [await dialog.locator('.sader-calendar-header>span').elementHandle(),title]);
  }
  const name = new Date(year,month-1,day).toLocaleDateString('es-PE',{day:'numeric',month:'long',year:'numeric'});
  await dialog.getByRole('button',{name,exact:true}).click();
  await dialog.waitFor({state:'hidden'});
}
export async function chooseTime(page, label, value) {
  const [hour,minute] = value.split(':').map(Number);
  await page.getByRole('button',{name:label,exact:true}).click();
  const dialog = page.getByRole('dialog',{name:label,exact:true});
  await dialog.getByRole('button',{name:`${((hour+11)%12)+1} ${hour < 12 ? 'AM' : 'PM'}`,exact:true}).click();
  await dialog.getByRole('button',{name:String(minute).padStart(2,'0'),exact:true}).click();
  await dialog.waitFor({state:'hidden'});
}
export async function chooseDateTime(page, value) {
  const [day,time] = value.split('T');
  await chooseDate(page,'Fecha y hora · fecha',day);
  await chooseTime(page,'Fecha y hora · hora',time);
}
