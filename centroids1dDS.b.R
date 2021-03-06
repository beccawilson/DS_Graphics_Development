#' 
#' @title Calculates the centroid of each n nearest neighbours
#' @description This function calculates the centroids for each n nearest neighbours.
#' @details The function finds the n-1 nearest neighbours of each data point in the 1-dimensional space.
#' The nearest neighbours are the data points with the minimum distances (in 1D, the distance is given 
#' by the difference between two values) from the point of interest. Each point of interest and its n-1
#' nearest neighbours are then used for the calculation of the centroid of those n points. The centroid
#' is the average value of the n nearest neighbours. The centroids are returned to the client side function
#' and can be used for the generation of non-disclosive graphs (e.g. histograms, boxplots, etc).    
#' @param x the name of a numeric vector, the x-variable.
#' @param n the number of the nearest neghbours for which their centroid is calculated.   
#' @return a vector with the centroids in 1D
#' @author Avraam, D.
#' @export
#' 
centroids1dDS.b <- function(x, n){

  # Load the RANN package to use the 'nn2' function that searches for the Nearest Neighbours  
  library(RANN)

  # Remove any missing values
  x <- na.omit(x)
  
  # standardise the variable
  x.standardised <- (x-mean(x))/sd(x)

  # Calculate the length of the variabld after ommitting any NAs 
  N.data <- length(x)

  # Capture the nfilter for centroids                       
  thr <- .AGGREGATE$listDisclosureSettingsDS.b()
  nf.centroids <- as.numeric(thr$nfilter.centroids) 
  
  # Check if n is integer and has a value greater than or equal to the pre-specified threshold 
  # and less than or equal to the length the variable minus the pre-specified threshold 
  if(n < nf.centroids | n > (N.data - nf.centroids)){   
    stop(paste0("n must be greater than or equal to ", nf.centroids, "and less than or equal to ", (N.data-nf.centroids), "."), call.=FALSE)
  }else{
    neighbours = n
  }

  # Find the n-1 nearest neighbours of each data point 
  nearest <- nn2(x.standardised, k = neighbours)
  
  # Calculate the centroid of each n nearest data points 
  x.centroid <- matrix()
  for (i in 1:N.data){
    x.centroid[i] <- mean(x.standardised[nearest$nn.idx[i,1:neighbours]])
  }

  # Calculate the scaling factor
  x.scalingFactor <- sd(x.standardised)/sd(x.centroid)

  # Apply the scaling factor to the centroids
  x.masked <- x.centroid * x.scalingFactor

  # Shift the centroids back to the actual position and scale of the original data
  x.new <- (x.masked * sd(x)) + mean(x)
  
  # Return the centroids
  return(x.new)

}
