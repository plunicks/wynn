print $ "1..3\n";

ok = load 'Test';

ns = get_namespace_root :wynn;

# Get a function from the HLL root namespace and use it:
lt = :wynn:::«<»;

ok $ lt 2 5;
ok $ ¬(lt 5 2);

# Lookup a function in the HLL namespace using Void:
p = ()::return;
ok $ (p 10) == 10;

()
