# Spirward

A tiny (256b) demo for DOS* featuring forward projection of a spiral.

## Math

### The Spiral Surface

The demo renders a 3D surface shaped like a spiral staircase. Mathematically, this surface is defined by _UV coordinates_, that is, two parameters:
- **u**: the vertical height that controls how far along the spiral you travel
- **v**: controls where you are around the circular cross-section (like walking around a tube)

For any pair of coordinates $(u, v)$, we compute a 3D point in space using:

$$
\begin{align*}
x &= R\sin(u) + r\cos(v) \\
y &= R\cos(u) - r\sin(v) \\
z &= u
\end{align*}
$$

where $R$ is the major radius (how far the spiral's center is from the origin) and $r$ is the minor radius (the thickness of the spiral tube). The second coordinate $v$ goes a full circle, that is $v\in [0, 2\pi]$.

### Perspective Projection

To display this 3D spiral on a 2D screen of certain width $W$ and height $H$, we use perspective projection—the same principle cameras use. Objects farther away appear smaller and closer to a vanishing point.

First, we transform the world coordinates into **camera space** by subtracting the camera position:

$$
\mathbf{P}_{\text{camera}} = \mathbf{P}_{\text{world}} - \mathbf{P}_{\text{eye}}
$$

This centers the coordinate system on the camera's viewpoint.

Then we project onto the screen plane using a pinhole camera model with focal length $f$, centered at the screen's middle:

$$
\begin{align*}
x_{\text{screen}} &= \frac{W}{2} + \frac{f \cdot x_{\text{camera}}}{z_{\text{camera}}} \\
y_{\text{screen}} &= \frac{H}{2} + \frac{f \cdot y_{\text{camera}}}{z_{\text{camera}}}
\end{align*}
$$

The division by $z_{\text{camera}}$ creates the perspective effect: points with larger $z$ (farther from camera) get divided by a bigger number, making them appear smaller and closer to the vanishing point.

### Sampling Strategy

Instead of blindly sampling the spiral at uniform $u$ intervals, we compute *which $u$ values will actually appear at each screen row* (more or less).

Assume for a moment that we **don't** center the height. Distant points get rendered at $y_{\text{screen}} = 0$, and the close ones have large $y_{\text{screen}}$. For a point on the spiral's central axis, the projection formula becomes:

$$
y_{\text{screen}} = \frac{f \cdot (0 - y_{\text{eye}})}{z - z_{\text{eye}}}
$$

Since $z = u$ for our spiral, we can solve for $u$:

$$
u = z_{\text{eye}} - \frac{f \cdot y_{\text{eye}}}{y_{\text{screen}}}
$$

By evaluating this formula for evenly-spaced screen rows ($y_{\text{screen}}$ from 1 to screen height), we get a list of $u$ values that map to those rows. These $u$ values are naturally denser where the perspective effect compresses more geometry—near the vanishing point at the top of the screen. We discarded the offset $\tfrac{H}{2}$ in our calculation, so the procedure above is a certain approximation only.

This gives us **non-uniform sampling tuned to the perspective distortion**, reducing gaps in coverage (and wasted precious samples that get rendered to the same screen pixels).

But what about $v$? How many points do we need? This will be explained in a further section.

### Texturing

Since we've got _UV coordinates_ at hand, it is very easy to draw textures on the surface.

#### Checkerboard Pattern

Of course, the classical checkerboard pattern comes very handy:

$$
\lfloor U\rfloor \oplus \lfloor V\rfloor = \begin{cases}
0,&\text{if }\lfloor U\rfloor + \lfloor V\rfloor \equiv 0 \pmod{2}\\
1,&\text{if }\lfloor U\rfloor + \lfloor V\rfloor \equiv 1 \pmod{2}
\end{cases}
$$

Setting $V = \tfrac{4v}{\pi}$ lets us divide spiral circles into equal eight parts, since $v \in [0, 2\pi]$. For the sake of simplicity, we can leave $U = u$.

#### Lighting Model

Realistic lighting often uses distance-based attenuation with formulas like $\frac{1}{1 + d^2}$ where $d$ is the distance from the camera. For our size-constrained demo, we use a simpler approximation that exploits the sampling strategy.

Recall that our sample points are indexed by $i$, where the sampling step is:

$$
v_{\text{step}} = \frac{\pi}{i}
$$

and the relationship between $u$ and the sampling index is:

$$
u = v_{\text{step}} \cdot f = \frac{\pi f}{i}
$$

where $f$ is the focal length. This means $i \propto \frac{1}{u}$, so using $i$ as a proxy for lighting gives us intensity roughly proportional to $\frac{1}{u}$—a crude but effective distance-based falloff.

#### Color Computation

The final pixel color combines the checkerboard pattern with the lighting:

$$
\text{color} = \text{pattern} \times \text{light}
$$

I think this is rather self-explanatory.

### Rasterization Procedure

So, in summary: for each sampled $(u, v)$ pair:
1. Compute the 3D surface point
2. Project it to screen coordinates
3. Calculate the color
4. Render to the screen

## Simplifications

Calculating everything directly from the formulas is definitely not a feasible way to write a demo, even using FPU. So we keep our constants simple ($0$ if possible), and it would be best to avoid factors (other than $1$, that is).

### General Parameters

We take $r = 1$ and $R = 1$, keeping things simple. Our camera has $z_{\text{eye}} = 0$. We are going to adjust $y_{\text{eye}}$ to be convenient for us.

### Sampling Strategy (Once Again)

First of all, we need to map all heights, from $1$ to $200$ (that's the target height dimension) to $u$'s. From our previous sampling formula, we naturally get:

$$
u_i = -\frac{f y_e}{i}
$$

for $i = 1, \ldots, 200$.

It turns out that letting $y_e = -2\pi$ simplifies a lot of calculations.

To render the surface, since we process each $(u, v)$ pair, we can do that straightforwardly using a double nested `for` loop. We defined $u$, but we still need to determine the number of samples for each $u$.

One may notice that for a fixed $u_i$, the image for $v \in [0, 2\pi]$ is actually a regular circle. Since our unit is a single pixel, we can calculate the circumference of the projected circle to get an estimate of the number of samples needed to fill the circle without gaps, but without too many wasted samples as well.

The circumference in question is:

$$
\frac{2\pi f}{u_i} = \frac{2\pi f}{-\tfrac{f y_e}{i}} = \frac{2\pi f i}{2\pi f} = i
$$

Isn't that nice?

#### Render Loop

Instead of recalculating the projection directly from the formula for every point, we use an incremental approach. For each $i$ (and its corresponding $u_i$), we calculate the initial projected position $(p_x, p_y)$ of the spiral's center at that height.

Let's introduce $v_{\text{step}} = \frac{\pi}{i}$. Since we need to sample around a full circle ($2\pi$), using this step size we'd need $2i$ steps. However, the current definition of $v_{\text{step}}$ turns out to be very convenient for the math that follows.

Recall the spiral surface formula with $r=1$ and $R=1$:

$$
\begin{align*}
x &= \sin(u) + \cos(v) \\
y &= \cos(u) - \sin(v) \\
z &= u
\end{align*}
$$

We split this into the **major radius** term (the spiral's central path) and the **minor radius** term (the tube cross-section). We compute the projected center position scaled by $\tfrac{1}{v_{\text{step}}}$:

$$
\begin{align*}
p_x &= \frac{\sin(u)}{v_{\text{step}}} = \frac{i \sin(u)}{\pi} \\
p_y &= \frac{\cos(u)}{v_{\text{step}}} = \frac{i \cos(u)}{\pi}
\end{align*}
$$

Now comes the clever part. As $v$ increases, the minor radius terms change, but instead of recomputing them from scratch, we use derivatives:

$$
\frac{d}{dv}[\cos(v)] = -\sin(v), \quad \frac{d}{dv}[-\sin(v)] = -\cos(v)
$$

For a step of size $\Delta v = 2v_{\text{step}}$, with positions scaled by $1/v_{\text{step}}$, the incremental updates work out to:

$$
\begin{align*}
p_x &\leftarrow p_x - \sin(v) \\
p_y &\leftarrow p_y - \cos(v)
\end{align*}
$$

And that's it. We essentialy walk around the circle incrementally.

I think that's enough. You're probably bored to death by now.

