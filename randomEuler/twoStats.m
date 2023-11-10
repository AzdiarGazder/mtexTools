function [m,s] = twoStats(x)
    arguments
        x (1,:) {mustBeNumeric}
    end
    m = mean(x,"all");
    s = std(x,1,"all");
end