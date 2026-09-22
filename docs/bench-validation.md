# Bench Validation (planned)

This protocol is written but hasn't been run. The Ag/AgCl paste and hydrogel arrived too late to assemble the pad. It follows DeMonte et al. (2005).

---

## Phantom

1. Place a copper plate at the base of the container as the return electrode.
2. Mix 2250 mL deionised water, 450 g animal-hide gelatin, 20.25 g NaCl and 30 mL Dettol.
3. Heat and stir until everything dissolves, then pour to about 9 cm deep.
4. Once set, apply a thin, even layer of thermochromic ink. It is opaque at room temperature and turns transparent above **30 °C**.

---

## Setup

- A digital camera records the pad–phantom interface throughout stimulation.
- A series shunt resistor gives real-time current measurement.
- The pad connects to a programmable current pulse generator, and the copper plate to the return terminal.

---

## Procedure

1. Let the phantom reach room temperature so the ink sits below 30 °C.
2. Attach the pad under controlled, repeatable pressure.
3. Apply a low-energy pulse train to confirm stable contact and correct current.
4. Stimulate with **14 ms pulses at 200 mA**.
5. Record video of the ink, the voltage across the pad–phantom system and the shunt current.
6. Rest between trials so the phantom returns to baseline and the ink turns opaque again.

---

## Analysis

| Measure | How |
|---|---|
| Hotspot location | Where the ink first clears: edge or centre |
| Effective impedance | Recorded voltage ÷ shunt current |
| Impedance drift | Change over repeated pulsing |
| Repeatability | Coefficient of variation per trial set |

Each configuration is run **n ≥ 3** times in random order. The perforated pad is compared with Mindray control pads using a two-sample Student's t-test on mean edge temperature rise (H₁: perforated < control, α = 0.05).

---

## Limitations

- The ink only shows the surface, while tissue damage depends on subsurface heating.
- It gives a threshold response, not a temperature. It can show that an area passed 30 °C, but not by how much.
- Fibre-optic probes would add depth-resolved temperature data.
