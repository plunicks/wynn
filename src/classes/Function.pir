.namespace ['Function']

.sub 'onload' :anon :load :init
    .local pmc meta, interp, core_type, hll_type
    meta = get_hll_global ['Object'], '!META'
    meta.'new_class'('Function', 'parent' => 'parrot;Sub Object')

    core_type = get_class 'Sub'
    hll_type = get_class 'Function'

    interp = getinterp
    interp.'hll_map'(core_type, hll_type)
.end
