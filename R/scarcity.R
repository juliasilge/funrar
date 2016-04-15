# Compute scarcity for a single community -----------------------------------
#
# Arguments:
#   com_table, a tidy data.frame of community with column with species, and
#   abundance
#
#   species, a character vector indicating the name of species column
#
#   abund, a character vector in the name of relative abundances column
#
#
# Output:
#   A tidy data.frame with a new column containing species scarcity

single_com_scar = function(com_table, species, abund) {

  # Computes scarcity by species
  N_sp = nrow(com_table)

  com_table[, "Si"] = exp(-N_sp * log(2) * com_table[, abund])

  return(com_table)
}

#' Scarcity
#'
#' Compute sparness values for several communities. Scarcity is computed per
#' community. Scarcity corresponds to the rareness of a given species in
#' terms of abundances, as such:
#' \deqn{
#'  S_i = \exp(-N\log{2}A_i),
#' }
#' with \eqn{S_i} the scarcity of species \eqn{i}, \eqn{N} the number of
#' species present in the given community and \eqn{A_i} the relative abundance
#' (in %%) of species \eqn{i}.
#'
#' @param com_table a data frame a tidy version of species in occurences in
#'     communities.
#'
#' @param species a character vector indicating the column of species in
#'     \code{com_table}
#'
#' @param com a character vector indicating the column name of communities ID
#'
#' @param abund a character vector indicating the column name of the relative
#'     abundances of species
#'
#' @return The same table as \code{com_table} with an added \eqn{S_i} column
#'     for Scarcity values.
#'
#' @export
scarcity = function(com_table, species, com, abund) {

  # Test to be sure
  if ((com %in% colnames(com_table)) == FALSE) {
    stop("Community table does not have any communities.")
  }

  if ((species %in% colnames(com_table)) == FALSE) {
    stop("Community table does not have any species.")
  }

  if (!is.character(com_table[, species])) {
    stop("Provided species are not character.")
  }

  if (is.null(abund)) {
    stop("No relative abundance provided.")
  }

  if (!is.numeric(com_table[, abund])) {
    stop("Provided abundances are not numeric.")
  }

  # Compute Scarcity
  # Split table by communities
  com_split = split(com_table, factor(com_table[[com]]))

  com_split = lapply(com_split,
                      function(one_com)
                        single_com_scar(one_com, species, abund)
  )

  com_scarcity = dplyr::bind_rows(com_split)

  return(com_scarcity)
}

#' Distinctiveness on presence/absence matrix
#'
#' Computes scarcity from a relative abundance matrix of species.
#'
#' Experimental for the moment, should be merged with previous function
#' 'scarcity()'
#'
#' @param pres_matrix a presence-absence matrix, with species in rows and sites
#'      in columns (not containing relative abundances for the moments)
#'
#'
#' @return a similar matrix to presence-absence with scarcity values
#'
#' @export
pres_scarcity = function(pres_matrix) {
  scarcity_mat = pres_matrix

  # Species with no relative abundance get a scarcity of 0
  scarcity_mat[scarcity_mat == 0] = NA

  # Compute total of nb of species per site (= per column)
  total_sites = apply(scarcity_mat, 2, function(x) sum(x != 0, na.rm = T))

  # Scarcity for each per row using total abundance vector
  scarcity_mat = apply(scarcity_mat, 1, function(x) {
    exp(-total_sites*log(2)*x)
  })

  return(t(scarcity_mat))
}