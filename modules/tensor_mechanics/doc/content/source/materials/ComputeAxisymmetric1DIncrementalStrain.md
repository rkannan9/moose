# Compute Axisymmetric 1D Incremental Strain

!syntax description /Materials/ComputeAxisymmetric1DIncrementalStrain

## Description

The material `ComputeAxisymmetric1DIncrementalStrain` calculates the small
incremental strain for 1D Axisymmetric systems and is intended for use with
[Generalized Plane Strain](tensor_mechanics/generalized_plane_strain.md) simulations.
This material assumes symmetry about the $z$-axis.
This 'strain calculator' material computes the strain within the cylindrical
coordinate system and relies on the specialized
[Axisymmetric RZ kernel](/StressDivergenceRZTensors.md) to handle the stress
divergence calculation.

!alert warning title=Symmetry Assumed About the $z$-axis
The axis of symmetry must lie along the $z$-axis in a $\left(r, z, \theta \right)$
cylindrical coordinate system. This symmetry orientation is required for the
calculation of the residual and of the jacobian.
See [StressDivergenceRZTensors](/StressDivergenceRZTensors.md) for the
residual equation and the germane discussion.

## 1D Axisymmetric Strain Formulation

The axisymmetric model uses the cylindrical coordinates, $r$, $z$, and $\theta$,
where the linear section formed by the $r$ axis is rotated about the $z$ axis in
the $\theta$ direction.
The small, total, strain increment is calculated with the form
\begin{equation}
  \label{eqn:strain_increment}
  \Delta \boldsymbol{\epsilon} = \frac{1}{2} \left( \boldsymbol{D} + \boldsymbol{D}^T \right)
  \text{ where } \boldsymbol{D} = \boldsymbol{A} - \bar{\boldsymbol{F}} + \boldsymbol{I}
\end{equation}
where $\boldsymbol{I}$ is the Rank-2 identity tensor and the deformation gradient,
$\boldsymbol{A}$, and the old deformation gradient,
$\bar{\boldsymbol{F}}$, are given as
\begin{equation}
  \label{eqn:deform_grads}
  \boldsymbol{A} = \begin{bmatrix}
                \epsilon_{rr} & 0 & 0 \\
                0 & \epsilon_{zz} & 0 \\
                0 & 0 & \epsilon_{\theta \theta}
              \end{bmatrix}
  \text{  and  }
  \bar{\boldsymbol{F}} = \begin{bmatrix}
                \epsilon_{rr}|_{old} & 0 & 0 \\
                0 & \epsilon_{zz}|_{old} & 0 \\
                0 & 0 & \epsilon_{\theta \theta}|_{old}
              \end{bmatrix}
\end{equation}
Note that $\bar{\boldsymbol{F}}$ uses the values of the strain expressions from
the previous time step.
The components of the tensors in [eqn:deform_grads] are given as
\begin{equation}
  \label{eqn:strain_components}
  \begin{aligned}
  \epsilon_{rr} & = u_{r,r} \\
  \epsilon_{zz} & = \epsilon|^{op} \\
  \epsilon_{\theta \theta} & = \frac{u_r}{X_r}
  \end{aligned}
\end{equation}
where $\epsilon|^{op}$ is a prescribed out-of-plane strain value: this strain
value can be given either as a scalar variable or a nonlinear variable.
The [Generalized Plane Strain](tensor_mechanics/generalized_plane_strain.md)
problems use scalar variables.
The value of the strain $\epsilon_{\theta \theta}$ depends on the displacement
and position in the radial direction.

!alert note title=Notation Order Change
The axisymmetric system changes the order of the displacement vector from
$(u_r, u_{\theta}, u_z)$, usually seen in textbooks, to $(u_r, u_z, u_{\theta})$.
Take care to follow this convention in your input files and when adding
eigenstrains or extra stresses.


## Example Input File

!alert note title=Use RZ Coordinate Type
The coordinate type in the Problem block of the input file must be set to
+`COORD_TYPE = RZ`+.

The common use of the `ComputeAxisymmetric1DIncrementalStrain` class is with the
[Generalized Plane Strain](tensor_mechanics/generalized_plane_strain.md) system;
this type of simulation uses the scalar strain variables

!listing modules/tensor_mechanics/test/tests/1D_axisymmetric/axisymm_gps_incremental.i block=Materials/strain

which uses a scalar variable for the coupled out-of-plane strain; the argument
for the `scalar_out_of_plane_strain` parameter is the name of the scalar strain
variable:

!listing modules/tensor_mechanics/test/tests/1D_axisymmetric/axisymm_gps_incremental.i block=Variables/scalar_strain_yy


!syntax parameters /Materials/ComputeAxisymmetric1DIncrementalStrain

!syntax inputs /Materials/ComputeAxisymmetric1DIncrementalStrain

!syntax children /Materials/ComputeAxisymmetric1DIncrementalStrain

!bibtex bibliography
