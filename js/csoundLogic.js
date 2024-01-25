// Modulo csound
const csoundjs = "./csound.js";
// Init Csound
let csound = null;

// CSD da passare a csound
const csd = "./main.csd";

// Pause
async function pause() {
  if (csound != null) await csound.pause();
}

// Main Function, entry point
async function start() {
  // Se non esiste nessuna instanza di csound
  if (csound == null) {
    // Import Metodo
    const { Csound } = await import(csoundjs);

    // Oggetto csound
    csound = await Csound();

    // passo il csd al bin web di csound
    await copyUrlToLocal(csd, csd);

    // carico le risorse
    const resources = ["./Resources/Impulse.wav"];

    // le passo al bin di csound
    await loadResources(csound, resources);

    // compilo il csd
    await csound.compileCsd(csd);

    // output console csound
    await csound.on("message", handleMessage);

    // set drywet
    await csound.setControlChannel("drywet", 0.5);
    // set gaain
    await csound.setControlChannel("gain", 0.5);

    // start the engine
    await csound.start();
  } else await csound.resume();
}
/*
 *code by victor lazzarini
 */
// Counter per print
let count = 0;

function handleMessage(message) {
  // get the display element (called console in the page)
  let element = document.getElementById("console");
  // add the message to HTML content (plus a newline)
  element.innerHTML += message + "\n";
  // focus on bottom, new messages make the display scroll down
  element.scrollTop = 99999;
  // clear display every 1000 lines
  if (count == 1000) {
    count = 0;
    element.innerHTML == "";
  }
  count += 1;
}

// Funzione per passare csd a bin web csound

/*
 *code by victor lazzarini
 */
async function copyUrlToLocal(src, dest) {
  // fetch the file
  let srcfile = await fetch(src);
  // get the file data as an array
  let dat = await srcfile.arrayBuffer();
  // write the data as a new file in the filesystem
  await csound.fs.writeFile(dest, new Uint8Array(dat));
}

// Passare risorse al bin csound (wav et simili)
const loadResources = async (csound, filesArray) => {
  for (let i = 0; i < filesArray.length; i++) {
    const fileUrl = filesArray[i];
    const f = await fetch(fileUrl);
    const fName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
    const path = `${fName}`;
    const buffer = await f.arrayBuffer();
    await csound.fs.writeFile(path, new Uint8Array(buffer));
  }
  return true;
};

// Funzione per prendere i valori da pagine web
/*
 *code by victor lazzarini
 */
async function setParameter(channel, value) {
  // set channelF
  if (csound) await csound.setControlChannel(channel, value);
  // update display
  document.getElementById(channel + "val").innerHTML = value;
}
