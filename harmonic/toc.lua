-- Return a table containing meta data that describes the package contents.
return {
  title = "Harmonic",
  author = "ars",
  name = "harmonic",
  units = {
    {
      -- Title and category control how this unit appears in the unit browser.
      title = "Harmonic Osc",
      category = "Oscillators",
      -- Which lua module contains the unit definition?
      moduleName = "Harmonic",
    },
  }
}

-- All packages must have this file!