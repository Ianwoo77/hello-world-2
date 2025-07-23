# Flexbox (2)

The CSS `box-sizing`property defines how the width and height of an element are calculated, including whether padding and borders are included in those dimensions.

- `content-box`(default)
  - Width and height apply only to the content.
  - Padding and borders are added *outside* the specified dimensions
- `border-box`
  - Width and height include content, padding and borders
  - Padding and borders are substracted from the specified dimenstions.

```html
<body>
    <div class="container">
        <header>
            <h1>Ink</h1>
        </header>

        <nav>
            <ul class="site-nav">
                <li><a href="/">Home</a></li>
                <li><a href="/features">Features</a></li>
                <li><a href="/pricing">Pricing</a></li>
                <li><a href="/support">Support</a></li>
                <li class="nav-right">
                    <a href="/about">About</a>
                </li>
            </ul>
        </nav>

        <main class="flex">
            <div class="column-main tile">
                <h1>Team collaboration done right</h1>
                <p>Thousands of teams from all over the
                    world turn to <b>Ink</b> to communicate
                    and get things done.</p>
            </div>
            <div class="column-sidebar">
                <div class="tile">
                    <form class="login-form">
                        <h3>Login</h3>
                        <p>
                            <label for="username">Username</label>
                            <input id="username" type="text" name="username" />
                        </p>
                        <p>
                            <label for="password">Password</label>
                            <input id="password" type="password" name="password" />
                        </p>
                        <button type="submit">Login</button>
                    </form>
                </div>
                <div class="tile centered stack">
                    <small>Starting at</small>
                    <div class="cost">
                        <span class="cost-currency">$</span>
                        <span class="cost-dollars">20</span>
                        <span class="cost-cents">.00</span>
                    </div>
                    <a class="cta-button" href="/pricing">
                        Sign up
                    </a>
                </div>
            </div>
        </main>
    </div>
</body>
```

And this HTML includes a link to css. Then for the css like:

```css
*,
::before,
::after {
    box-sizing: border-box;
}

body {
    margin: unset;
    background-color: #709b90;
    font-family: Helvetica, sans-serif;
}

.stack>*+* {
    margin-block-start: 1.5em;
}

.container {
    max-inline-size: 1080px;
    margin-inline: auto;
}
```

#### Building a basic flexbox menu

For this, want the navigational menu to look like -- Most of the menu items will algin to the left, but move one over to the right side - To build, just should consider with element needs to be the flex container, keeping in mind that its child elements will become the flex items.

```css
.site-nav {
    display: flex;
    padding: unset;
    list-style-type: none;
    background-color: #5f4b44;
}

.site-nav>li>a {
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}
```

Then adding padding and spacing -- like:

```css
.site-nav {
    display: flex;
    padding: 0.5rem;
    // ...
}

.site-nav>li>a {
    display: block;
    padding: .5em 1em;
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}
```

Effect of `display:block`on `<a>`elements -- 

- Each link takes up the full width of its parent `<li>`.
- The `padding`and `background-color`apply uniformly across the entire block.
- Makes links block-level, so they add to the parent element’s height

Just note that the flexbox allows to use `margin:auto`to fill all available space between flex items.

```css
.site-nav {
    display: flex;
    padding: 0.5rem;
    gap: var(--gap-size);
    list-style-type: none;
    background-color: #5f4b44;
}

.site-nav > .nav-right {
    margin-inline-start: auto;
}
```

When it comes to sizing flexbox elements, canuse the `width`and `height`, but also provides more options for sizing then these props alone like:

```css
.tile {
    padding: 1.5em;
    background-color: #fff;
}

.flex {
    display: flex;
    gap : var(--gap-size);
}
```

The `flex`prop is shorthand for 3 different sizing properties -- `flex-grow, flex-shrink, flex-basis`. For this:

```css
flex-grow:2;
flex-shrink: 1;
flex-basis: 0%;
```

#### Flex grow

Once `flex-basis`is computed for each flex item, they will add up to some width. This width may not necessarily fill the width of the flex container, leaving a remainder. The remainder space will be consumed by the flex items based on their `flex-grow`. The `flex-shrink`value for each item indicates whether it should shrink to prevent overflow. Cuz the `flex-shrink`follows similar principles as `flex-grow`-- after determining the initial main size of the flex items, they could *exceed the size avaialble* in the flex container. 

##### Some practical examples

Can make use of the `flex`prop in countless ways -- fore:
`flex:none`-- items grows to their natrual width
`flex: 0 0 300px, flex: 1`-- The second item fills all remaining

#### Changing the flex direction

What need is for the two columns to grow if necessary to fill the container’s height. Turn the right column into a flex container with a `flex-direction: column`then apply a non-zero `flex-grow`to both tiles within.

```css
.column-sidebar {
    flex:1;
    display: flex;
    flex-direction: column;
    gap: var(--gap-size);
}

.column-sidebar > .tile {
    flex: 1;
}
```

