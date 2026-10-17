/**
 * Flutter Web Bootstrap Loader
 * Trust Juggler // Driver Engine
 */
class FlutterLoader {
  constructor() {
    this._didCreateEngineInitializerResolve = null;
    this.didCreateEngineInitializer = new Promise((resolve) => {
      this._didCreateEngineInitializerResolve = resolve;
    });
  }

  loadEntrypoint(options) {
    const { onEntrypointLoaded } = options || {};
    const engineInitializer = {
      initializeEngine: async () => {
        return {
          runApp: () => {
            console.log('[FlutterLoader] Trust Juggler Driver Web App Initialized.');
          }
        };
      }
    };
    if (onEntrypointLoaded) {
      onEntrypointLoaded(engineInitializer);
    }
    return Promise.resolve();
  }
}

window._flutter = {
  loader: new FlutterLoader()
};
