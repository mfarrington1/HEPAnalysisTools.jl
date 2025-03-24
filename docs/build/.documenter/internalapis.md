
## Internal
<details class='jldocstring custom-block' open>
<summary><a id='DarkQCD.@fourmomenta-Tuple{Any, Any}' href='#DarkQCD.@fourmomenta-Tuple{Any, Any}'><span class="jlbinding">DarkQCD.@fourmomenta</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@fourmomenta evt obj_prefix
```


Creates the fourmomenta for a given object type in the event. Returns a StructArray of LorentzVectorCyl.

It assumes that the event is a structure containig all the projections of the 4-vectors: evt.obj_pt, evt.obj_eta, evt.obj_phi, evt.obj_m (or evt.obj_E for jets).

Concretely,

```julia
@fourmomenta evt ph
```


would expand to:

```julia
StructArray(LorentzVectorCyl(
    evt.ph_pt,
    evt.ph_eta,
    evt.ph_phi,
    evt.ph_m
))
```


For jets, it will call `fromPtEtaPhiE` and the return type stays the same.

**Example**

```julia
julia> for evt in tree
            hlt_jets = @fourmomenta evt jet
            count(>(25), hlt_jets.pt) # count how many jets have pt > 25 GeV
            ...
        end
```


