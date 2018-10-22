#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ::Title:: *)
(*Basic Functionality Package*)


BeginPackage["BasicFunctions`"];


(* ::Chapter:: *)
(*Function Usage*)


USolve::usage="Solve for Time evolution operator given Hamiltonian";
DensityMatrix::usage="Outputs density matrix given a wave function(Pure State for now)";


Begin["`Private`"];


\[HBar]=1;

(* How to approximately check PositiveSemidefinite *)
DensityMatrixQ[A_?SquareMatrixQ]:=Block[{},(Tr[A]==1)&&(PositiveSemidefiniteMatrixQ[A])&&(HermitianMatrixQ[A])];

WaveFunction::imaginaryMessage="Non-trivial imaginary part";
WaveFunction[\[Theta]_,\[Phi]_]:=Block[{},
If[ Im[\[Theta]]>10^(-6)||  Im[\[Phi]]>10^(-6),Message[\[Psi]::imaginaryMessage]];
Cos[\[Theta]/2]{{1},{0}}+Sin[\[Theta]/2]Exp[I \[Phi]]{{0},{1}}];

USolve[Ham_,UInit_,tMin_?NumericQ,tMax_?NumericQ,\[HBar]_?NumericQ,opts___]:=
	Block[{USol,tSol,intdF,t},
        intdF=USol/.NDSolve[{I \[HBar] USol'[tSol]==Ham[tSol].USol[tSol],USol[tMin]==UInit},USol,{tSol,tMin,tMax},opts]//First;
        Function[{t},intdF[t]//Evaluate]
    ];
    
    
DensityMatrix[\[Psi]_]:=\[Psi].ConjugateTranspose[\[Psi]];

BlochVector[\[Rho]_]:={
 \[Rho][[2,1]]+\[Rho][[1,2]],(\[Rho][[2,1]]-\[Rho][[1,2]])/I,2\[Rho][[1,1]]-1
}//Chop;

(* Loss of Precision *)
EvolveDensityMatrix[\[Rho]_?DensityMatrixQ,U_,t_]:=U[t].\[Rho].ConjugateTranspose[U[t]]//Chop;

BlochPlot[\[Rho]_?DensityMatrixQ,U_,tMin_,tMax_]:=Block[{a},
a[t_]:=BlochVector[EvolveDensityMatrix[\[Rho],U,t]];
Show[SphericalPlot3D[1,{\[Theta],0,Pi},{\[Phi],0,2Pi},PlotStyle->{Opacity[.2],Gray},MeshStyle->{Opacity[.1]}],ParametricPlot3D[{a[t][[1]],a[t][[2]],a[t][[3]]},{t,tMin,tMax},PlotStyle->{Thick,Red}]]];

RandomDensityMatrix[dim_]:=Block[{m=RandomComplex[{-1-I,1+I},{dim,dim}],h=(m+ConjugateTranspose[m])/2},
 h.ConjugateTranspose[h]/Tr[h.ConjugateTranspose[h]]
 ];

PureStateQ[\[Rho]_?DensityMatrixQ]:=\[Rho]==\[Rho].\[Rho];

BlochListPlot[list__,args___]:=Block[{points},
points=BlochVector/@list;
ListPointPlot3D[points,BoxRatios->{1, 2, 1}]];

SquarePulseHamiltonian[\[Tau]_,\[CapitalOmega]_,\[Omega]_,E0_,E1_,t_]:=Block[{H0=E0 {{1},{0}}.{{1,0}}+E1 {{0},{1}}.{{0,1}},Hp=\[CapitalOmega] Cos[\[Omega] t]({{1},{0}}.{{0,1}}+{{0},{1}}.{{1,0}})},H0+Hp( UnitStep[t]- UnitStep[t-\[Tau]])];

SquarePulseSoln[\[Tau]_?NumericQ,\[CapitalOmega]_?NumericQ,\[Omega]_?NumericQ,E0_?NumericQ,E1_?NumericQ]:=Block[{H},
H[t_]:=SquarePulseHamiltonian[\[Tau],\[CapitalOmega],\[Omega],E0,E1,t];
USolve[H,IdentityMatrix[2],0,10,\[HBar]]];

TransitionProbibility[t_,U_,i_,j_]:=Abs[U[t][[i,j]]]^2;

(* Set up git *)



(* ::Section:: *)
(*End*)


End[]
EndPackage[]