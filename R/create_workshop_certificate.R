#' Create certificates for all attendees
#'
#' @param date Date of the workshop, as a date.
#' @param location Location of the workshop, character.
#' @param workshop Workshop title, character.
#' @param curriculum Path to the workshop curriculum (.md), character.
#' @param certifier Person certifying, character.
#' @param credentials Credentials of the certifying person, character.
#' @param attendees Names of attendees, character vector.
#' @param dir Directory where to output the pdf certificates, character.
#' @param papersize Option for LaTeX article class specifying paper size, e.g.
#' `"a4paper"`, `"letterpaper"`.
#' @param keep_tex Logical argument passed to rmarkdown::render
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Fake names generated via charlatan::ch_name
#' attendees <- c("Marnie Dickinson", "Dr. Marlin Wilderman")
#' date <- as.Date("2018-01-01")
#' location <- "University of Lorraine"
#' workshop <- "Package development workshop"
#' curriculum <- system.file("rmarkdown", "templates",
#' "workshop_certificate", "resources",
#' "default_workshop_contents.md", package = "fwdbrand")
#' certifier <- "Zaire Crooks"
#' credentials <- "Forwards teaching team member"
#' dir <- "certificates"
#' create_workshop_certificates(date, location, workshop, curriculum,
#'  certifier,
#' credentials,
#' attendees,
#' dir)
#' }
create_workshop_certificates <- function(date, location, workshop, curriculum,
                                         certifier, credentials, attendees,
                                         dir, papersize = "a4paper",
                                         keep_tex = FALSE){

    if(!dir.exists(dir)){
        dir.create(dir)
    }
    file.copy(system.file("rmarkdown", "templates",
                          "workshop_certificate", "skeleton",
                          "skeleton.Rmd", package = "fwdbrand"),
              file.path(dir, "skeleton.Rmd"))
    file.copy(system.file("rmarkdown", "templates",
                          "workshop_certificate", "skeleton",
                          "file.tex", package = "fwdbrand"),
              file.path(dir, "file.tex"))
    file.copy(system.file("extdata", "assets",
                          "partly_transparent_forwards_borders.png", package = "fwdbrand"),
              file.path(dir, "logo.png"))


    purrr::walk2(attendees, 1:length(attendees),
                 create_workshop_certificate,
                 date, location, workshop,
                 curriculum, certifier,
                 credentials,
                 dir, papersize, keep_tex)

   file.remove(file.path(dir, "skeleton.Rmd"))
   file.remove(file.path(dir, "file.tex"))
   file.remove(file.path(dir, "logo.png"))
}

# https://tex.stackexchange.com/questions/346730/fancyhdr-package-not-working
create_workshop_certificate <- function(attendee, number,
                                        date, location, workshop,
                                        curriculum, certifier,
                                        credentials,
                                        dir, papersize, keep_tex){
    rmarkdown::render(input = file.path(dir, "skeleton.Rmd"),
                      output_file = paste0(snakecase::to_snake_case(paste(workshop,
                                                                   stringr::str_pad(number, 2, pad = "0"))),
                                           ".pdf"),
                      output_dir = dir,
                      params = list(papersize = papersize,
                                    date = date,
                                    location = location,
                                    workshop = workshop,
                                    curriculum = curriculum,
                                    certifier = certifier,
                                    credentials = credentials,
                                    attendee = attendee),
                      output_options = list(keep_tex = keep_tex))
}
