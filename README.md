# Expressivity Comparison Test (ECT)


The ECT is a test for comparison of expressive interpretations of music.


## Citation

We also advise mentioning the software versions you used,
in particular the versions of the `ECT` and `psychTestR` packages.
You can find these version numbers from R by running the following commands:

``` r
library(ECT)
library(psychTestR)
if (!require(devtools)) install.packages("devtools")
x <- devtools::session_info()
x$packages[x$packages$package %in% c("ECT", "psychTestR"), ]
```

## Installation instructions (local use)

1. If you don't have R installed, install it from here: https://cloud.r-project.org/

2. Open R.

3. Install the ‘devtools’ package with the following command:

`install.packages('devtools')`

4. Install the ECT:

`devtools::install_github('klausfrieler/ECT')`

## Usage

### Quick demo 

You can demo the ECT at the R console, as follows:

``` r
# Load the ECT package
library(ECT)

# Run a demo test, with feedback as you progress through the test,
# and not saving your data
ECT_demo()

# Run a demo test, skipping the training phase, and only asking 5 questions, as well a changing the language
ECT_demo(num_items = 5, language = "en")
```

### Testing a participant

The `ECT_standalone()` function is designed for real data collection.
In particular, the participant doesn't receive feedback during this version.

``` r
# Load the ECT package
library(ECT)

# Run the test as if for a participant, using default settings,
# saving data, and with a custom admin password
ECT_standalone(admin_password = "put-your-password-here")
```

You will need to enter a participant ID for each participant.
This will be stored along with their results.

Each time you test a new participant,
rerun the `ECT_standalone()` function,
and a new participation session will begin.

You can retrieve your data by starting up a participation session,
entering the admin panel using your admin password,
and downloading your data.
For more details on the psychTestR interface, 
see http://psychtestr.com/.

The ECT currently supports English (en), German (de), Russian (ru), and Nederlands (nl).
You can select one of these languages by passing a language code as 
an argument to `ECT_standalone()`, e.g. `ECT_standalone(languages = "de")`,
or alternatively by passing it as a URL parameter to the test browser,
eg. http://127.0.0.1:4412/?language=DE (note that the `p_id` argument must be empty).

## Installation instructions (Shiny Server)

1. Complete the installation instructions described under 'Local use'.
2. If not already installed, install Shiny Server Open Source:
https://www.rstudio.com/products/shiny/download-server/
3. Navigate to the Shiny Server app directory.

`cd /srv/shiny-server`

4. Make a folder to contain your new Shiny app.
The name of this folder will correspond to the URL.

`sudo mkdir ECT`

5. Make a text file in this folder called `app.R`
specifying the R code to run the app.

- To open the text editor: `sudo nano ECT/app.R`
- Write the following in the text file:

``` r
library(ECT)
ECT_standalone(admin_password = "put-your-password-here")
```

- Save the file (CTRL-O).

6. Change the permissions of your app directory so that `psychTestR`
can write its temporary files there.

`sudo chown -R shiny ECT`

where `shiny` is the username for the Shiny process user
(this is the usual default).

7. Navigate to your new shiny app, with a URL that looks like this:
`http://my-web-page.org:3838/ECT

## Implementation notes

By default, the ECT  implementation always estimates participant abilities
using weighted-likelihood estimation.
We adopt weighted-likelihood estimation for this release 
because this technique makes fewer assumptions about the participant group being tested.
This makes the test better suited to testing with diverse participant groups
(e.g. children, clinical populations).

## Usage notes

- The ECT runs in your web browser.
- By default, image files are hosted online on our servers.
The test therefore requires internet connectivity.
