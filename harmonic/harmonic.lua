local app = app
local Class = require "Base.Class"
local Unit = require "Unit"
local Pitch = require "Unit.ViewControl.Pitch"
local GainBias = require "Unit.ViewControl.GainBias"
local Encoder = require "Encoder"
local libcore = require "core.libcore"

-- Create a new class definition.
local Harmonic = Class {}
-- This how we derive from an existing class, in this case, Unit.
Harmonic:include(Unit)

-- The class constructor
function Harmonic:init(args)
    -- Units are constructed with a table of parameters passed in as args.
    -- This is the title that is displayed in the unit header.
    args.title = "harm osc"
    -- This is a 2-letter code displayed in places where space is minimal.
    args.mnemonic = "HO"
    -- A version that is saved with presets that can be used during deserialization.
    args.version = 2
    -- Construct the parent class.
    Unit.init(self, args)
end

-- This method is called during unit construction.  Construct the DSP graph here.
function Harmonic:onLoadGraph(channelCount)

    --- Control objects (FADERS)
    local tune = self:addObject("tune", app.ConstantOffset())
    local tuneRange = self:addObject("tuneRange", app.MinMax())
    local f0 = self:addObject("f0", app.GainBias())
    local f0Range = self:addObject("f0Range", app.MinMax())
    local phase = self:addObject("phase", app.GainBias())
    local phaseRange = self:addObject("phaseRange", app.MinMax())
    local fdbk = self:addObject("fdbk", app.GainBias())
    local fdbkRange = self:addObject("fdbkRange", app.MinMax())
    local centerControl = self:addObject("centerControl", app.GainBias())
    local centerControlRange = self:addObject("centerControlRange", app.MinMax())
    local f1 = self:addObject("f1", app.GainBias())
    local f1Range = self:addObject("f1Range", app.MinMax())
    local f2 = self:addObject("f2", app.GainBias())
    local f2Range = self:addObject("f2Range", app.MinMax())
    local f3 = self:addObject("f3", app.GainBias())
    local f3Range = self:addObject("f3Range", app.MinMax())
    local f4 = self:addObject("f4", app.GainBias())
    local f4Range = self:addObject("f4Range", app.MinMax())
    local f5 = self:addObject("f5", app.GainBias())
    local f5Range = self:addObject("f5Range", app.MinMax())
    local f6 = self:addObject("f6", app.GainBias())
    local f6Range = self:addObject("f6Range", app.MinMax())
    local f7 = self:addObject("f7", app.GainBias())
    local f7Range = self:addObject("f7Range", app.MinMax())
    local f8 = self:addObject("f8", app.GainBias())
    local f8Range = self:addObject("f8Range", app.MinMax())

    local bwidth = self:addObject("bwidth", app.ParameterAdapter())
    local xfade = self:addObject("xfade", app.ParameterAdapter())

    connect(tune, "Out", tuneRange, "In")
    connect(f0, "Out", f0Range, "In")
    connect(phase, "Out", phaseRange, "In")
    connect(fdbk, "Out", fdbkRange, "In")
    connect(centerControl, "Out", centerControlRange, "In")

    -- Common branches
    self:addMonoBranch("tune", tune, "In", tune, "Out")
    self:addMonoBranch("f0", f0, "In", f0, "Out")
    self:addMonoBranch("phase", phase, "In", phase, "Out")
    self:addMonoBranch("fdbk", fdbk, "In", fdbk, "Out")

    self:addMonoBranch("bwidth", bwidth, "In", bwidth, "Out")
    self:addMonoBranch("xfade", xfade, "In", xfade, "Out")
    self:addMonoBranch("centerControl", centerControl, "In", centerControl, "Out")
    self:addMonoBranch("f1", f1, "In", f1, "Out")
    self:addMonoBranch("f2", f2, "In", f2, "Out")
    self:addMonoBranch("f3", f3, "In", f3, "Out")
    self:addMonoBranch("f4", f4, "In", f4, "Out")
    self:addMonoBranch("f5", f5, "In", f5, "Out")
    self:addMonoBranch("f6", f6, "In", f6, "Out")
    self:addMonoBranch("f7", f7, "In", f7, "Out")
    self:addMonoBranch("f8", f8, "In", f8, "Out")

    -- DSP objects
    ----------------- Mixer
    local numMixerChannels = 8
    local myMixer = self:addObject("myMixer", app.Mixer(numMixerChannels))
    myMixer:hardSet("Gain1", 0.25) -- TESTING: get this number right
    myMixer:hardSet("Gain2", 0.25)
    myMixer:hardSet("Gain3", 0.25)
    myMixer:hardSet("Gain4", 0.25)
    myMixer:hardSet("Gain5", 0.25)
    myMixer:hardSet("Gain6", 0.25)
    myMixer:hardSet("Gain7", 0.25)
    myMixer:hardSet("Gain8", 0.25)

    ----------------- Harmonics
    local f1Osc = self:addObject("f1Osc", libcore.SineOscillator())
    local f2Osc = self:addObject("f2Osc", libcore.SineOscillator())
    local f3Osc = self:addObject("f3Osc", libcore.SineOscillator())
    local f4Osc = self:addObject("f4Osc", libcore.SineOscillator())
    local f5Osc = self:addObject("f5Osc", libcore.SineOscillator())
    local f6Osc = self:addObject("f6Osc", libcore.SineOscillator())
    local f7Osc = self:addObject("f7Osc", libcore.SineOscillator())
    local f8Osc = self:addObject("f8Osc", libcore.SineOscillator())

	----------------- Limiter
	local limiter = self:addObject("limiter", libcore.Limiter())

    connect(tune, "Out", f1Osc, "V/Oct")
    connect(f0, "Out", f1Osc, "Fundamental")
    connect(phase, "Out", f1Osc, "Phase")
    connect(fdbk, "Out", f1Osc, "Feedback")

    local f2HarmOffset = self:addObject("f2HarmOffset", app.ConstantGain())
    f2HarmOffset:hardSet("Gain", 2) -- Offsetting the harmonics

    connect(tune, "Out", f2Osc, "V/Oct")
    connect(f0, "Out", f2HarmOffset, "In")
    connect(f2HarmOffset, "Out", f2Osc, "Fundamental")
    connect(phase, "Out", f2Osc, "Phase")
    connect(fdbk, "Out", f2Osc, "Feedback")

    local f3HarmOffset = self:addObject("f3HarmOffset", app.ConstantGain())
    f3HarmOffset:hardSet("Gain", 3) -- Offsetting the harmonics

    connect(tune, "Out", f3Osc, "V/Oct")
    connect(f0, "Out", f3HarmOffset, "In")
    connect(f3HarmOffset, "Out", f3Osc, "Fundamental")
    connect(phase, "Out", f3Osc, "Phase")
    connect(fdbk, "Out", f3Osc, "Feedback")

    local f4HarmOffset = self:addObject("f4HarmOffset", app.ConstantGain())
    f4HarmOffset:hardSet("Gain", 4) -- Offsetting the harmonics

    connect(tune, "Out", f4Osc, "V/Oct")
    connect(f0, "Out", f4HarmOffset, "In")
    connect(f4HarmOffset, "Out", f4Osc, "Fundamental")
    connect(phase, "Out", f4Osc, "Phase")
    connect(fdbk, "Out", f4Osc, "Feedback")

    local f5HarmOffset = self:addObject("f5HarmOffset", app.ConstantGain())
    f5HarmOffset:hardSet("Gain", 5) -- Offsetting the harmonics

    connect(tune, "Out", f5Osc, "V/Oct")
    connect(f0, "Out", f5HarmOffset, "In")
    connect(f5HarmOffset, "Out", f5Osc, "Fundamental")
    connect(phase, "Out", f5Osc, "Phase")
    connect(fdbk, "Out", f5Osc, "Feedback")

    local f6HarmOffset = self:addObject("f6HarmOffset", app.ConstantGain())
    f6HarmOffset:hardSet("Gain", 6) -- Offsetting the harmonics

    connect(tune, "Out", f6Osc, "V/Oct")
    connect(f0, "Out", f6HarmOffset, "In")
    connect(f6HarmOffset, "Out", f6Osc, "Fundamental")
    connect(phase, "Out", f6Osc, "Phase")
    connect(fdbk, "Out", f6Osc, "Feedback")

    local f7HarmOffset = self:addObject("f7HarmOffset", app.ConstantGain())
    f7HarmOffset:hardSet("Gain", 7) -- Offsetting the harmonics

    connect(tune, "Out", f7Osc, "V/Oct")
    connect(f0, "Out", f7HarmOffset, "In")
    connect(f7HarmOffset, "Out", f7Osc, "Fundamental")
    connect(phase, "Out", f7Osc, "Phase")
    connect(fdbk, "Out", f7Osc, "Feedback")

    local f8HarmOffset = self:addObject("f8HarmOffset", app.ConstantGain())
    f8HarmOffset:hardSet("Gain", 8) -- Offsetting the harmonics

    connect(tune, "Out", f8Osc, "V/Oct")
    connect(f0, "Out", f8HarmOffset, "In")
    connect(f8HarmOffset, "Out", f8Osc, "Fundamental")
    connect(phase, "Out", f8Osc, "Phase")
    connect(fdbk, "Out", f8Osc, "Feedback")

    ----------------- Bumpmaps to control harmonics 
    local f1Bump = self:addObject("f1Bump", libcore.BumpMap())
    f1Bump:hardSet("Height", 1.0)
    f1Bump:hardSet("Center", 0.063)
    tie(f1Bump, "Width", bwidth, "Out")
    tie(f1Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f1Bump, "In")

    local f2Bump = self:addObject("f2Bump", libcore.BumpMap())
    f2Bump:hardSet("Height", 1.0)
    f2Bump:hardSet("Center", 0.188)
    tie(f2Bump, "Width", bwidth, "Out")
    tie(f2Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f2Bump, "In")

    local f3Bump = self:addObject("f3Bump", libcore.BumpMap())
    f3Bump:hardSet("Height", 1.0)
    f3Bump:hardSet("Center", 0.313)
    tie(f3Bump, "Width", bwidth, "Out")
    tie(f3Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f3Bump, "In")

    local f4Bump = self:addObject("f4Bump", libcore.BumpMap())
    f4Bump:hardSet("Height", 1.0)
    f4Bump:hardSet("Center", 0.438)
    tie(f4Bump, "Width", bwidth, "Out")
    tie(f4Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f4Bump, "In")

    local f5Bump = self:addObject("f5Bump", libcore.BumpMap())
    f5Bump:hardSet("Height", 1.0)
    f5Bump:hardSet("Center", 0.563)
    tie(f5Bump, "Width", bwidth, "Out")
    tie(f5Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f5Bump, "In")

    local f6Bump = self:addObject("f6Bump", libcore.BumpMap())
    f6Bump:hardSet("Height", 1.0)
    f6Bump:hardSet("Center", 0.688)
    tie(f6Bump, "Width", bwidth, "Out")
    tie(f6Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f6Bump, "In")

    local f7Bump = self:addObject("f7Bump", libcore.BumpMap())
    f7Bump:hardSet("Height", 1.0)
    f7Bump:hardSet("Center", 0.813)
    tie(f7Bump, "Width", bwidth, "Out")
    tie(f7Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f7Bump, "In")

    local f8Bump = self:addObject("f8Bump", libcore.BumpMap())
    f8Bump:hardSet("Height", 1.0)
    f8Bump:hardSet("Center", 0.938)
    tie(f8Bump, "Width", bwidth, "Out")
    tie(f8Bump, "Fade", xfade, "Out")
    connect(centerControl, "Out", f8Bump, "In")

    ----------------- Control objects for individual harmonics' VCAs
    local f1BumpVCA = self:addObject("f1BumpVCA", app.Multiply())
    local f1Negate = self:addObject("f1Negate", app.ConstantGain())
    f1Negate:hardSet("Gain", -1)
    local f1PlusOne = self:addObject("f1PlusOne", app.Constant())
    f1PlusOne:hardSet("Value", 1)
    local f1Bias = self:addObject("f1Bias", app.Sum())
    local f1Offset = self:addObject("f1Offset", app.Sum())
    local f1VCA = self:addObject("f1VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    local f2BumpVCA = self:addObject("f2BumpVCA", app.Multiply())
    local f2Negate = self:addObject("f2Negate", app.ConstantGain())
    f2Negate:hardSet("Gain", -1)
    local f2PlusOne = self:addObject("f2PlusOne", app.Constant())
    f2PlusOne:hardSet("Value", 1)
    local f2Bias = self:addObject("f2Bias", app.Sum())
    local f2Offset = self:addObject("f2Offset", app.Sum())
    local f2VCA = self:addObject("f2VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    local f3BumpVCA = self:addObject("f3BumpVCA", app.Multiply())
    local f3Negate = self:addObject("f3Negate", app.ConstantGain())
    f3Negate:hardSet("Gain", -1)
    local f3PlusOne = self:addObject("f3PlusOne", app.Constant())
    f3PlusOne:hardSet("Value", 1)
    local f3Bias = self:addObject("f3Bias", app.Sum())
    local f3Offset = self:addObject("f3Offset", app.Sum())
    local f3VCA = self:addObject("f3VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    local f4BumpVCA = self:addObject("f4BumpVCA", app.Multiply())
    local f4Negate = self:addObject("f4Negate", app.ConstantGain())
    f4Negate:hardSet("Gain", -1)
    local f4PlusOne = self:addObject("f4PlusOne", app.Constant())
    f4PlusOne:hardSet("Value", 1)
    local f4Bias = self:addObject("f4Bias", app.Sum())
    local f4Offset = self:addObject("f4Offset", app.Sum())
    local f4VCA = self:addObject("f4VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    local f5BumpVCA = self:addObject("f5BumpVCA", app.Multiply())
    local f5Negate = self:addObject("f5Negate", app.ConstantGain())
    f5Negate:hardSet("Gain", -1)
    local f5PlusOne = self:addObject("f5PlusOne", app.Constant())
    f5PlusOne:hardSet("Value", 1)
    local f5Bias = self:addObject("f5Bias", app.Sum())
    local f5Offset = self:addObject("f5Offset", app.Sum())
    local f5VCA = self:addObject("f5VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    local f6BumpVCA = self:addObject("f6BumpVCA", app.Multiply())
    local f6Negate = self:addObject("f6Negate", app.ConstantGain())
    f6Negate:hardSet("Gain", -1)
    local f6PlusOne = self:addObject("f6PlusOne", app.Constant())
    f6PlusOne:hardSet("Value", 1)
    local f6Bias = self:addObject("f6Bias", app.Sum())
    local f6Offset = self:addObject("f6Offset", app.Sum())
    local f6VCA = self:addObject("f6VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    local f7BumpVCA = self:addObject("f7BumpVCA", app.Multiply())
    local f7Negate = self:addObject("f7Negate", app.ConstantGain())
    f7Negate:hardSet("Gain", -1)
    local f7PlusOne = self:addObject("f7PlusOne", app.Constant())
    f7PlusOne:hardSet("Value", 1)
    local f7Bias = self:addObject("f7Bias", app.Sum())
    local f7Offset = self:addObject("f7Offset", app.Sum())
    local f7VCA = self:addObject("f7VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    local f8BumpVCA = self:addObject("f8BumpVCA", app.Multiply())
    local f8Negate = self:addObject("f8Negate", app.ConstantGain())
    f8Negate:hardSet("Gain", -1)
    local f8PlusOne = self:addObject("f8PlusOne", app.Constant())
    f8PlusOne:hardSet("Value", 1)
    local f8Bias = self:addObject("f8Bias", app.Sum())
    local f8Offset = self:addObject("f8Offset", app.Sum())
    local f8VCA = self:addObject("f8VCA", app.Multiply()) -- Audio VCA for harmonics' outputs

    -- Control paths connections
    connect(f1, "Out", f1Negate, "In") -- invert
    connect(f1, "Out", f1Range, "In")
    connect(f1, "Out", f1Offset, "Right")
    connect(f1Negate, "Out", f1Bias, "Left")
    connect(f1PlusOne, "Out", f1Bias, "Right")
    connect(f1Bias, "Out", f1BumpVCA, "Right")
    connect(f1Bump, "Out", f1BumpVCA, "Left")
    connect(f1BumpVCA, "Out", f1Offset, "Left")
    connect(f1Offset, "Out", f1VCA, "Right")
    -- Audio path
    connect(f1Osc, "Out", f1VCA, "Left")
    connect(f1VCA, "Out", myMixer, "In1")

    connect(f2, "Out", f2Negate, "In") -- invert
    connect(f2, "Out", f2Range, "In")
    connect(f2, "Out", f2Offset, "Right")
    connect(f2Negate, "Out", f2Bias, "Left")
    connect(f2PlusOne, "Out", f2Bias, "Right")
    connect(f2Bias, "Out", f2BumpVCA, "Right")
    connect(f2Bump, "Out", f2BumpVCA, "Left")
    connect(f2BumpVCA, "Out", f2Offset, "Left")
    connect(f2Offset, "Out", f2VCA, "Right")
    connect(f2Osc, "Out", f2VCA, "Left")
    connect(f2VCA, "Out", myMixer, "In2")

    connect(f3, "Out", f3Negate, "In") -- invert
    connect(f3, "Out", f3Range, "In")
    connect(f3, "Out", f3Offset, "Right")
    connect(f3Negate, "Out", f3Bias, "Left")
    connect(f3PlusOne, "Out", f3Bias, "Right")
    connect(f3Bias, "Out", f3BumpVCA, "Right")
    connect(f3Bump, "Out", f3BumpVCA, "Left")
    connect(f3BumpVCA, "Out", f3Offset, "Left")
    connect(f3Offset, "Out", f3VCA, "Right")
    connect(f3Osc, "Out", f3VCA, "Left")
    connect(f3VCA, "Out", myMixer, "In3")

    connect(f4, "Out", f4Negate, "In") -- invert
    connect(f4, "Out", f4Range, "In")
    connect(f4, "Out", f4Offset, "Right")
    connect(f4Negate, "Out", f4Bias, "Left")
    connect(f4PlusOne, "Out", f4Bias, "Right")
    connect(f4Bias, "Out", f4BumpVCA, "Right")
    connect(f4Bump, "Out", f4BumpVCA, "Left")
    connect(f4BumpVCA, "Out", f4Offset, "Left")
    connect(f4Offset, "Out", f4VCA, "Right")
    connect(f4Osc, "Out", f4VCA, "Left")
    connect(f4VCA, "Out", myMixer, "In4")

    connect(f5, "Out", f5Negate, "In") -- invert
    connect(f5, "Out", f5Range, "In")
    connect(f5, "Out", f5Offset, "Right")
    connect(f5Negate, "Out", f5Bias, "Left")
    connect(f5PlusOne, "Out", f5Bias, "Right")
    connect(f5Bias, "Out", f5BumpVCA, "Right")
    connect(f5Bump, "Out", f5BumpVCA, "Left")
    connect(f5BumpVCA, "Out", f5Offset, "Left")
    connect(f5Offset, "Out", f5VCA, "Right")
    connect(f5Osc, "Out", f5VCA, "Left")
    connect(f5VCA, "Out", myMixer, "In5")

    connect(f6, "Out", f6Negate, "In") -- invert
    connect(f6, "Out", f6Range, "In")
    connect(f6, "Out", f6Offset, "Right")
    connect(f6Negate, "Out", f6Bias, "Left")
    connect(f6PlusOne, "Out", f6Bias, "Right")
    connect(f6Bias, "Out", f6BumpVCA, "Right")
    connect(f6Bump, "Out", f6BumpVCA, "Left")
    connect(f6BumpVCA, "Out", f6Offset, "Left")
    connect(f6Offset, "Out", f6VCA, "Right")
    connect(f6Osc, "Out", f6VCA, "Left")
    connect(f6VCA, "Out", myMixer, "In6")

    connect(f7, "Out", f7Negate, "In") -- invert
    connect(f7, "Out", f7Range, "In")
    connect(f7, "Out", f7Offset, "Right")
    connect(f7Negate, "Out", f7Bias, "Left")
    connect(f7PlusOne, "Out", f7Bias, "Right")
    connect(f7Bias, "Out", f7BumpVCA, "Right")
    connect(f7Bump, "Out", f7BumpVCA, "Left")
    connect(f7BumpVCA, "Out", f7Offset, "Left")
    connect(f7Offset, "Out", f7VCA, "Right")
    connect(f7Osc, "Out", f7VCA, "Left")
    connect(f7VCA, "Out", myMixer, "In7")

    connect(f8, "Out", f8Negate, "In") -- invert
    connect(f8, "Out", f8Range, "In")
    connect(f8, "Out", f8Offset, "Right")
    connect(f8Negate, "Out", f8Bias, "Left")
    connect(f8PlusOne, "Out", f8Bias, "Right")
    connect(f8Bias, "Out", f8BumpVCA, "Right")
    connect(f8Bump, "Out", f8BumpVCA, "Left")
    connect(f8BumpVCA, "Out", f8Offset, "Left")
    connect(f8Offset, "Out", f8VCA, "Right")
    connect(f8Osc, "Out", f8VCA, "Left")
    connect(f8VCA, "Out", myMixer, "In8")

    -- Here we connect the outlet of the final Mixer object to the output of the unit (which is actually an inlet).
    connect(myMixer, "Out", limiter, "In")
	connect(limiter, "Out", self, "Out1")

    -- Handle stereo case here by connecting up the 2nd channel as well.
    if channelCount > 1 then
        connect(self.objects.myMixer, "Out", self, "Out2")
    end
end

-- A shared instance of the views table to save resources.
-- The views table determines the order in which controls appear for each view.
local views = {
    -- The default (expanded) view for a unit.
    expanded = {"tune", "f0", "phase", "fdbk", "centerControl", "bwidth", "xfade", "f1", "f2", "f3", "f4", "f5", "f6",
                "f7", "f8"},
    -- Generally the collapsed view has no controls, but it could have some if you desire.
    collapsed = {}
}

-- map for individual harmonics' faders
local function decibelMap(from, to)
    local map = app.LinearDialMap(from, to)
    map:setZero(-60)
    map:setSteps(6, 1, 0.1, 0.01);
    return map
end

local harmMap = decibelMap(-60, 0)

-- This method is called during construction.  Define the views and their controls here.
function Harmonic:onLoadViews(objects, branches)
    local controls = {}

    -- There are many types of controls, each deriving from Unit.ViewControl.

    -- The Pitch control is offset-type control specifically designed for 1V/octave parameters.
    controls.tune = Pitch {
        -- The label that sits above the button (Mx).
        button = "V/oct",
        -- Which branch does this control manage?
        branch = branches.tune,
        -- The description label shown in the sub display when this control is focused.
        description = "V/oct",
        -- The object that should be wrapped by this Pitch control.
        offset = objects.tune,
        -- The object that keeps track of certain statistics used for rendering modulation.
        range = objects.tuneRange
    }

    -- The GainBias is the most common control.  
    -- It is also commonly referred to as an attenuverter plus offset in modularspeak.
    controls.f0 = GainBias {
        button = "f0",
        description = "Fundamental",
        branch = branches.f0,
        -- The object that this control wraps.
        gainbias = objects.f0,
        range = objects.f0Range,
        -- The dial map for the bias fader.  
        -- Dial maps control how encoder motion relates to changes in the value of the underlying parameter.
        biasMap = Encoder.getMap("oscFreq"),
        -- Display units.
        biasUnits = app.unitHertz,
        -- You can optionally set an initial value for the bias here.
        initialBias = 27.5,
        -- Same as for the bias, but this is the dial map for the gain parameter.
        gainMap = Encoder.getMap("freqGain"),
        -- This only affects how the fader position is drawn.
        scaling = app.octaveScaling
    }

    controls.phase = GainBias {
        button = "phase",
        description = "Phase Offset",
        branch = branches.phase,
        gainbias = objects.phase,
        range = objects.phaseRange,
        biasMap = Encoder.getMap("[-1,1]"),
        initialBias = 0.0
    }

    controls.fdbk = GainBias {
        button = "fdbk",
        description = "Feedback",
        branch = branches.fdbk,
        gainbias = objects.fdbk,
        range = objects.fdbkRange,
        biasMap = Encoder.getMap("[-1,1]"),
        initialBias = 0
    }

    -- BumpMap controls
    controls.centerControl = GainBias {
        button = "center",
        branch = branches.centerControl,
        description = "Center",
        gainbias = objects.centerControl,
        range = objects.centerControlRange,
        biasMap = Encoder.getMap("[0,1]"),
        biasUnits = app.unitNone,
        initialBias = 0.05,
        gainMap = Encoder.getMap("gain")
    }

    controls.bwidth = GainBias {
        button = "width",
        branch = branches.bwidth,
        description = "Width",
        gainbias = objects.bwidth,
        range = objects.bwidth,
        biasMap = Encoder.getMap("unit"),
        biasUnits = app.unitNone,
        initialBias = 0.15,
        gainMap = Encoder.getMap("gain")
    }

    controls.xfade = GainBias {
        button = "xfade",
        branch = branches.xfade,
        description = "xFade",
        gainbias = objects.xfade,
        range = objects.xfade,
        biasMap = Encoder.getMap("unit"),
        biasUnits = app.unitNone,
        initialBias = 0.15,
        gainMap = Encoder.getMap("gain")
    }

    controls.f1 = GainBias {
        button = "1",
        branch = branches.f1,
        description = "Harm1",
        gainbias = objects.f1,
        range = objects.f1Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    controls.f2 = GainBias {
        button = "2",
        branch = branches.f2,
        description = "Harm2",
        gainbias = objects.f2,
        range = objects.f2Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    controls.f3 = GainBias {
        button = "3",
        branch = branches.f3,
        description = "Harm3",
        gainbias = objects.f3,
        range = objects.f3Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    controls.f4 = GainBias {
        button = "4",
        branch = branches.f4,
        description = "Harm4",
        gainbias = objects.f4,
        range = objects.f4Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    controls.f5 = GainBias {
        button = "5",
        branch = branches.f5,
        description = "Harm5",
        gainbias = objects.f5,
        range = objects.f5Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    controls.f6 = GainBias {
        button = "6",
        branch = branches.f6,
        description = "Harm6",
        gainbias = objects.f6,
        range = objects.f6Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    controls.f7 = GainBias {
        button = "7",
        branch = branches.f7,
        description = "Harm7",
        gainbias = objects.f7,
        range = objects.f7Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    controls.f8 = GainBias {
        button = "8",
        branch = branches.f8,
        description = "Harm8",
        gainbias = objects.f8,
        range = objects.f8Range,
        biasMap = harmMap,
        biasUnits = app.unitDecibels,
        initialBias = 0.001,
        gainMap = Encoder.getMap("gain"),
        scaling = app.decibelScaling

    }

    -- This method expects us to return the table of controls and views.
    return controls, views
end

-- Return the class definition.
return Harmonic
