$title GAMS Quick Reference Card  


*------------------------------------------------------------------------	
* Comments       
*------------------------------------------------------------------------

* Comment lines start with a "*"
* To have in-line comments, e.g. after a "#", use
$eolcom #


*------------------------------------------------------------------------	
* Parameters       
*------------------------------------------------------------------------

parameters # let's declare 7 scalar parameters, of which 3 are also initialized.
    param_name_up_to_63_characters  explanatory text up to 255 char long
    no_space_or_special_char 'spaces ok here, and special chars too w/ quotes'
    cAse_iNsEnSiTiVe    "don't forget the unit [m/s]"
    long_enough_to_be_self_explanatory / 0.1 /
    param1  'comma needed if more params on same line' / 1 /, param2 / 2 /
    param3  "otherwise comma between params is optional"
;

* You can evaluate math expressions and assign them to previously declared
* parameters
case_insensitive = 1+1;

* Another parameter
parameter single_parameter '"parameter" or "parameters" are equivalent';

* In math expressions you can use only parameters that have been assigned
* some value before.
single_parameter = 3
* Be aware of the spaces before asterisks!
    *sqrt(case_insensitive+5)**5;


*------------------------------------------------------------------------	
* Variables       
*------------------------------------------------------------------------

variables
    SAME_NAME_RULES_AS_PARAMS 'I am free and ready to be optimized'
    WOULD_LIKE_SOME_BOUNDS 'bounds can be set later'
    WOULD_LIKE_SOME_FIXING 'if level = lower bound = upper, variable is fixed'
;

variable OBJ 'at least one unrestricted var MUST be available (= f.obj.)';

* Variables declared above can range from minus to plus infinity. To set bounds:
* a) during declaration
variable WLSB / lo 0, up 100 /;
* b) after declaration
WOULD_LIKE_SOME_BOUNDS.lo = -inf;
WOULD_LIKE_SOME_BOUNDS.up = 100;

* To fix a variable
variable WLSF / fx 10 /;
WOULD_LIKE_SOME_FIXING.fx = 10;
* To unfix, reset lower and upper bounds.

* To init the level of a variable
variable WLSL / l 50 /;
WOULD_LIKE_SOME_BOUNDS.l = (WOULD_LIKE_SOME_BOUNDS.lo +
         WOULD_LIKE_SOME_BOUNDS.up)/2;


*------------------------------------------------------------------------	
* Equations       
*------------------------------------------------------------------------

equations
    eqx_lessthan 'equations include inequalities'
    eqy_greaterthan 'inequalities are never strict'
    eqobj 'one equation MUST be used to define the objective function variable'
;

variables
    X 'decision variable 1' / lo 0.1 /
    Y 'decision variable 2' / up 1 /
    OBJ 'objective function variable'
;

eqx_lessthan..
    X =l= -Y**3+1
;

eqy_greaterthan..
    Y =g= log(X)
;

eqobj..
    OBJ =e= X - Y
;


*------------------------------------------------------------------------	
* Model & Solve       
*------------------------------------------------------------------------

model min_lp_some_equations 'include only some equations in the model'
        / eq1, eq2 /;
model max_nlp_all_equations 'include all equations' / all /;

* Models have attributes. Some are used before the solve command.
min_lp_some_equations.sysout = 1;
max_nlp_all_equations.solprint = 0;
max_nlp_all_equations.iterlim = 1e6;
max_nlp_all_equations.reslim = 3600;

solve min_lp_some_equations minimizing OBJ using lp;

* Some attributes are relevant after the solve command.
* Relational operators: gt (>), ge (>=), lt (<), le(<=), eq (=), ne (<>)
* Boolean operators: not, or, and
abort$(
    (min_lp_some_equations.solvestat gt %Solvestat.Normal Completion%)
    or (min_lp_some_equations.modelstat gt %ModelStat.Optimal%))
         'Problem not solved correctly!';

solve max_nlp_all_equations maximizing OBJ using nlp;

abort$(not (
    (max_nlp_all_equations.solvestat eq 1)
    and (max_nlp_all_equations.modelstat le 2))) # %ModelStat.Locally Optimal%
         'Problem not solved correctly!';

variable X / l 1 /, OBJ;
equation eqobj;
parameter a / 1 /;
eqobj.. OBJ =e= a*X**0.1+4*X+4;
model xsquared / all /;

for(a = -1 to 1 by 1,
    display a;
    solve xsquared minimizing OBJ using nlp;

    if(((xsquared.solvestat gt 1)
        or (xsquared.modelstat gt 2)),
        display 'Model not solved correctly, but still going on',
            xsquared.solvestat, xsquared.modelstat;
    else
        display X.l, OBJ.l;
* To change displayed decimal points:
        option X:0;
        display 'W/o decimals', X.l, OBJ.l;
    );
);