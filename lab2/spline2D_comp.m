
function spline2D_comp()
data = load('data/21x25.mat');
spline2Duniform(data.knot_vectorx, data.knot_vectory, data.coeffs);
return

function t=check_sanity(knot_vector,p)

  initial = knot_vector(1);
  kvsize = size(knot_vector,2);

  t = true;
  counter = 1;

  for i=1:p+1
    if (initial ~= knot_vector(i))
      t = false;
      return
    end
  end


  for i=p+2:kvsize-p-1
    if (initial == knot_vector(i))
      counter = counter + 1;
      if (counter > p)
        t = false;
        return
      end
    else
      initial = knot_vector(i);
      counter = 1;
    end
  end

  initial = knot_vector(kvsize);

  for i=kvsize-p:kvsize
    if (initial ~= knot_vector(i))
      t = false;
      return
    end
  end
  
  for i=1:kvsize-1
    if (knot_vector(i)>knot_vector(i+1))
      t = false;
    end
  end

  return
end

function spline2Duniform(knot_vectorx, knot_vectory, coeffs)

precision = 0.01;

%macros
compute_nr_basis_functions = @(knot_vector,p) size(knot_vector, 2) - p - 1;
mesh   = @(a,c) (a:precision*(c-a):c);

%splines in x
px = compute_p(knot_vectorx);
check_sanity(knot_vectorx,px);
nrx = compute_nr_basis_functions(knot_vectorx,px);

x_begin = knot_vectorx(1);
x_end = knot_vectorx(size(knot_vectorx,2));

x=mesh(x_begin,x_end);

%splines in y
py = compute_p(knot_vectory);
check_sanity(knot_vectory,py);
nry = compute_nr_basis_functions(knot_vectory,py);

y_begin = knot_vectory(1);
y_end = knot_vectory(size(knot_vectory,2));

y=mesh(y_begin,y_end);

%X and Y coordinates of points over the 2D mesh
[X,Y]=meshgrid(x,y);

% Code modifications

coeff_nrows = size(coeffs, 1);
coeff_ncols = size(coeffs, 2);
if (coeff_nrows ~= nry || coeff_ncols ~= nrx)
    disp("[Input Error]: It's definitely one of the coeffs of all time:")
    fprintf("\tGot: nrows: %d, ncolumns: %d\n", coeff_nrows, coeff_ncols)
    fprintf("\tExpected: nrows: %d, ncolumns: %d\n\n", nry, nrx)
    return
end

M = zeros(size(X));
for i=1:nrx
  vx=compute_spline(knot_vectorx,px,i,X);
  for j=1:nry
    vy=compute_spline(knot_vectory,py,j,Y);
    M = M + coeffs(j, i) * vx .* vy;
  end
end

figure('Name','Maze 3D view');
surf(X,Y, M);
set(gca, "YDir", "reverse");

figure('Name','Maze 3D view cropped');
surf(X,Y, M);
zlim([0.7, 1])
set(gca, "YDir", "reverse");

% Code modifications end

end


function p=compute_p(knot_vector)

  initial = knot_vector(1);
  kvsize = size(knot_vector,2);
  i=1;

  while (i+1 < kvsize) && (initial == knot_vector(i+1))
    i=i+1;
  end
  
  p = i-1;
  
  return
end

function y=compute_spline(knot_vector,p,nr,x)
  
  fC= @(x,a,b) (x)/(b-a)-a/(b-a);
  fD= @(x,c,d) (1-x)/(d-c)+(d-1)/(d-c);
  
  
  a = knot_vector(nr);
  b = knot_vector(nr+p);
  c = knot_vector(nr+1);
  d = knot_vector(nr+p+1);

  if (p==0)
    y = 0 .* (x < a) + 1 .* (a <= x & x <= d) + 0 .* (x > d);
    return
  end
  
  lp = compute_spline(knot_vector,p-1,nr,x);
  rp = compute_spline(knot_vector,p-1,nr+1,x);
  
  if (a==b)
    y1 = 0 .* (x < a) + 1 .* (a <= x & x <= b) + 0 .* (x > b);
  else
    y1 = 0 .* (x < a) + fC(x,a,b) .* (a <= x & x <= b) + 0 .* (x > b);
  end
  
  if (c==d)
    y2 = 0 .* (x < c) + 1 .* (c < x & x <= d) + 0 .* (d < x);
  else
    y2 = 0 .* (x < c) + fD(x,c,d) .* (c < x & x <= d) + 0 .* (d < x);
  end
  
  y = lp .* y1 + rp .* y2;
  return
  
end

end