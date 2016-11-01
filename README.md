# How to save data in MATLAB


In this document I look at different ways of saving data in MATLAB. We want to save data so that: 
* we can save many different variables (time series or images that are co-acquired)
* we can save data without knowing in advance how long each time series is going to be
* not every trial saves all the variables
* a new variable can be saved after N trials
* we want to read individual trials from saved data efficiently 

The only way I know of reading part of data in `.mat` file is to use `matfile`. This means that there is only way you can save data that satisfies all the conditions listed above. 

### This is what works

I found that this is the best data format to satisfy these conditions:

```matlab
% this will become the k2data dormat
% here, the index of each structure index over the trial
variable1(1).data = randn(1000,100);
variable2(1).data = randn(1000,100);

variable1(2).data = randn(1000,100);
variable2(2).data = [];

% and so on
save('data.mat','variable1','variable2')
```

Here is a plot showing how fast it is to read data in this format, compared to another format that supports partial loading of data (see below):

![](.images/metrics.png)


### These data formats don't work:

This one doesn't work because you need to load the entire data file into memory to determine what the variable names are:

```matlab
% this is referred to as "simple structure"
% a matfile contains a variable called data
data(1).variable1 = randn(100,100);
data(1).variable2 = randn(1000,100);

data(2).variable1 = randn(100,100);
data(2).variable2 = [];

% and so on
```

This one doesn't work because `matfile` can't index into cell arrays:

```matlab
variable1{1} = randn(1001,1);
variable2{1} = randn(1001,1);

variable1{2} = randn(1001,1);
variable2{1} = [];

% and so on
```

This one doesn't work because `matfile` can't index into cell elements of structure arrays


```matlab
data.variable1{1} = randn(1001,1);
data.variable2{1} = randn(1001,1);

data.variable1{2} = randn(1001,1);
data.variable2{2} = [];

% and so on
```

