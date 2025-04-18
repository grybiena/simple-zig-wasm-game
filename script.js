var memory = new WebAssembly.Memory({
    // See build.zig for reasoning
    initial: 180 /* pages */,
    maximum: 180 /* pages */,
});

var importObject = {
    env: {
        consoleLog: (arg) => console.log(arg), // Useful for debugging on zig's side
        memory: memory,
    },
};



WebAssembly.instantiateStreaming(fetch("zig-out/bin/main.wasm"), importObject).then((result) => {
    const wasmMemoryArray = new Uint8Array(memory.buffer);


    // Automatically set canvas size as defined in `main.zig`
    const canvasSize = result.instance.exports.getCanvasSize();
    const canvas = document.getElementById("canvas");
    canvas.width = canvasSize;
    canvas.height = canvasSize;

    const context = canvas.getContext("2d");
    const imageData = context.createImageData(canvas.width, canvas.height);
    context.clearRect(0, 0, canvas.width, canvas.height);


    document.body.onkeydown = function(e) {
      if (e.code === "ArrowRight" || e.code === "KeyD") {
        result.instance.exports.onInput(3);
      }
      if (e.code === "ArrowLeft" || e.code === "KeyA") {
        result.instance.exports.onInput(2);
      }
      if (e.code === "ArrowUp" || e.code === "KeyW") {
        result.instance.exports.onInput(0);
      }
      if (e.code === "ArrowDown" || e.code === "KeyS") {
        result.instance.exports.onInput(1);
      }
    };

    result.instance.exports.seedRng(BigInt(Math.floor(Math.random()*1000000)));

    const drawCanvas = () => {
        result.instance.exports.drawCanvas();

        const bufferOffset = result.instance.exports.getCanvasBufferPointer();
        const imageDataArray = wasmMemoryArray.slice(
            bufferOffset,
            bufferOffset + canvasSize * canvasSize * 4
        );

        imageData.data.set(imageDataArray);

        context.clearRect(0, 0, canvas.width, canvas.height);
        context.putImageData(imageData, 0, 0);
    };

    drawCanvas ();
    console.log(memory.buffer);
    setInterval(() => {
        drawCanvas();
    }, 200);
});

