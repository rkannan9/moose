# two-phase version
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 30
  xmin = 0
  xmax = 15
[]


[GlobalParams]
  richardsVarNames_UO = PPNames
[]

[Functions]
  [./dts]
    type = PiecewiseLinear
    y = '0.1 0.5 0.5 1 2  4'
    x = '0   0.1 1   5 40 42'
  [../]
[]

[UserObjects]
  [./PPNames]
    type = RichardsVarNames
    richards_vars = 'pwater pgas'
  [../]
  [./DensityWater]
    type = RichardsDensityConstBulk
    dens0 = 1000
    bulk_mod = 2E6
  [../]
  [./DensityGas]
    type = RichardsDensityConstBulk
    dens0 = 1
    bulk_mod = 2E6
  [../]
  [./SeffWater]
    type = RichardsSeff2waterVG
    m = 0.8
    al = 1E-5
  [../]
  [./SeffGas]
    type = RichardsSeff2gasVG
    m = 0.8
    al = 1E-5
  [../]
  [./RelPermWater]
    type = RichardsRelPermPower
    simm = 0.0
    n = 2
  [../]
  [./RelPermGas]
    type = RichardsRelPermPower
    simm = 0.0
    n = 2
  [../]
  [./SatWater]
    type = RichardsSat
    s_res = 0.0
    sum_s_res = 0.0
  [../]
  [./SatGas]
    type = RichardsSat
    s_res = 0.0
    sum_s_res = 0.0
  [../]
  [./SUPGwater]
    type = RichardsSUPGstandard
    p_SUPG = 1E-5
  [../]
  [./SUPGgas]
    type = RichardsSUPGstandard
    p_SUPG = 1E-5
  [../]
[]

[Variables]
  [./pwater]
    order = FIRST
    family = LAGRANGE
  [../]
  [./pgas]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./Seff1VG_Aux]
  [../]
  [./bounds_dummy]
  [../]
[]


[Kernels]
  active = 'richardsfwater richardstwater richardsfgas richardstgas'
  [./richardstwater]
    type = RichardsMassChange
    variable = pwater
  [../]
  [./richardsfwater]
    type = RichardsFlux
    variable = pwater
  [../]
  [./richardstgas]
    type = RichardsMassChange
    variable = pgas
  [../]
  [./richardsfgas]
    type = RichardsFlux
    variable = pgas
  [../]
  [./richardsppenalty]
    type = RichardsPPenalty
    variable = pgas
    a = 1E-18
    lower_var = pwater
  [../]
[]

[AuxKernels]
  [./Seff1VG_AuxK]
    type = RichardsSeffAux
    variable = Seff1VG_Aux
    seff_UO = SeffWater
    pressure_vars = 'pwater pgas'
  [../]
[]

[Bounds]
  [./pwater_upper_bounds]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = pwater
    bound_type = upper
    bound_value = 1E7
  [../]
  [./pwater_lower_bounds]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = pwater
    bound_type = lower
    bound_value = -310000
  [../]
[]


[ICs]
  [./water_ic]
    type = FunctionIC
    variable = pwater
    function = initial_water
  [../]
  [./gas_ic]
    type = FunctionIC
    variable = pgas
    function = initial_gas
  [../]
[]

[BCs]
  [./left_w]
    type = DirichletBC
    variable = pwater
    boundary = left
    value = 1E6
  [../]
  [./left_g]
    type = DirichletBC
    variable = pgas
    boundary = left
    value = 1E6
  [../]
  [./right_w]
    type = DirichletBC
    variable = pwater
    boundary = right
    value = -300000
  [../]
  [./right_g]
    type = DirichletBC
    variable = pgas
    boundary = right
    value = 0
  [../]
[]


[Functions]
  [./initial_water]
    type = ParsedFunction
    expression = 1000000*(1-min(x/5,1))-300000*(max(x-5,0)/max(abs(x-5),1E-10))
  [../]
  [./initial_gas]
    type = ParsedFunction
    expression = max(1000000*(1-x/5),0)+1000
  [../]
[]


[Materials]
  [./rock]
    type = RichardsMaterial
    block = 0
    mat_porosity = 0.15
    mat_permeability = '1E-10 0 0  0 1E-10 0  0 0 1E-10'
    density_UO = 'DensityWater DensityGas'
    relperm_UO = 'RelPermWater RelPermGas'
    SUPG_UO = 'SUPGwater SUPGgas'
    sat_UO = 'SatWater SatGas'
    seff_UO = 'SeffWater SeffGas'
    viscosity = '1E-3 1E-6'
    gravity = '0 0 0'
    linear_shape_fcns = true
  [../]
[]


[Preconditioning]
  active = 'standard'

  [./bounded]
  # must use --use-petsc-dm command line argument
    type = SMP
    full = true
    petsc_options = '-snes_converged_reason'
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it -snes_type -ksp_rtol -ksp_atol'
    petsc_options_value = 'bcgs bjacobi 1E-10 1E-10 50 vinewtonssls 1E-20 1E-20'
  [../]

  [./standard]
    type = SMP
    full = true
    petsc_options = '-snes_converged_reason'
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type -snes_atol -snes_rtol -snes_max_it -ksp_rtol -ksp_atol'
    petsc_options_value = 'gmres asm lu NONZERO 1E-10 1E-10 20 1E-20 1E-20'
  [../]

[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 50

  [./TimeStepper]
    type = FunctionDT
    function = dts
  [../]
[]

[Outputs]
  file_base = bl20
  execute_on = 'initial timestep_end final'
  interval = 10000
  exodus = true
  hide = pgas
[]
