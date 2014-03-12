.namespace ['Object']

.sub 'onload' :anon :init :load
    .local pmc meta
    $P0 = get_root_global ['parrot'], 'P6metaclass'
    $P0.'new_class'('Object')
    meta = $P0.'HOW'()
    set_hll_global ['Object'], '!META', meta
.end
