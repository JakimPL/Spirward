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
y &= R\cos(u) + r\sin(v) \\
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

For a point on the spiral's central axis (where the spiral tube is thinnest in screen space), the projection formula becomes:

$$
y_{\text{screen}} = \frac{f \cdot (0 - y_{\text{eye}})}{z - z_{\text{eye}}}
$$

Since $z = u$ for our spiral, we can solve for $u$:

$$
u = z_{\text{eye}} - \frac{f \cdot y_{\text{eye}}}{y_{\text{screen}}}
$$

By evaluating this formula for evenly-spaced screen rows ($y_{\text{screen}}$ from 1 to screen height), we get a list of $u$ values that map to those rows. These $u$ values are naturally denser where the perspective effect compresses more geometry—near the vanishing point at the top of the screen.

This gives us **non-uniform sampling tuned to the perspective distortion**, reducing gaps in coverage (and wasted precious samples that get rendered to the same screen pixels).

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

Setting $V = \frac{4v}{\pi}$ lets us divide spiral circles into equal eight parts, since $v \in [0, 2\pi]$. For the sake of simplicity, we can leave $U = u$.

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

where the pattern value modulates the lighting intensity to create the textured appearance.

### Rasterization Procedure

So, in summary: for each sampled $(u, v)$ pair:
1. Compute the 3D surface point
2. Project it to screen coordinates
3. Calculate the color
4. Render to the screen
