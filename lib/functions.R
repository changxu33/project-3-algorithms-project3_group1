######################################################
### Memory-based Collaborative Filtering Algorithm ###
######################################################

### Project 3
### ADS Spring 2018
### Group 1

MS_data_transform <- function(MS) {
  
  ## Calculate UI matrix for Microsoft data
  ## Input: data - Microsoft data in original form
  ## Output: UI matrix
  
  # Find sorted lists of users and vroots
  users  <- sort(unique(MS$V2[MS$V1 == "C"]))
  vroots <- sort(unique(MS$V2[MS$V1 == "V"]))
  
  nu <- length(users)
  nv <- length(vroots)
  
  # Initiate the UI matrix
  UI            <- matrix(0, nrow = nu, ncol = nv)
  row.names(UI) <- users
  colnames(UI)  <- vroots
  
  user_locs <- which(MS$V1 == "C")
  
  # Cycle through the users and place 1's for the visited vroots
  for (i in 1:nu) {
    name     <- MS$V2[user_locs[i]]
    this_row <- which(row.names(UI) == name)
    
    # Find the vroots
    if (i == nu) {
      v_names <- MS$V2[(user_locs[i] + 1):nrow(MS)]
    } else {
      v_names <- MS$V2[(user_locs[i] + 1):(user_locs[i+1] - 1)]
    }  
    
    # Place the 1's
    UI[this_row, colnames(UI) %in% v_names] <- 1
  }
  return(UI)
}

movie_data_transform <- function(movie) {
  
  ## Calculate UI matrix for eachmovie data
  ## Input: data - movie data in original form
  ## Output: UI matrix
    
  # Find sorted lists of users and vroots
  users  <- sort(unique(movie$User))
  movies <- sort(unique(movie$Movie))
  
  # Initiate the UI matrix
  UI            <- matrix(NA, nrow = length(users), ncol = length(movies))
  row.names(UI) <- users
  colnames(UI)  <- movies
  
  # Cycle through the users, finding the user's movies and ratings
  for (i in 1:length(users)) {
    user    <- users[i]
    movies  <- movie$Movie[movie$User == user]
    ratings <- movie$Score[movie$User == user]
    
    ord     <- order(movies)
    movies  <- movies[ord]
    ratings <- ratings[ord]
    
    # Note that this relies on the fact that things are ordered
    UI[i, colnames(UI) %in% movies] <- ratings
  }
  return(UI)
}  

calc_weight <- function(data, method = "pearson") {
  
  ## Calculate similarity weight matrix
  ## Input: data    - movie data or MS data in user-item matrix form
  ##        method  - 'pearson', 'psig', 'pvar', 'spearman', 
  ##                  'vector', 'entropy', 'msd', 'simrank'
  ## Output: similarity weight matrix
    
  # Iniate the similarity weight matrix
  data       <- as.matrix(data)
  weight_mat <- matrix(NA, nrow = nrow(data), ncol = nrow(data))

  # Calculate item-wise variances and weights
  variances <- apply(data, 2, var, na.rm = TRUE)
  var.min <- min(variances, na.rm = TRUE)
  var.max <- max(variances, na.rm = TRUE)
  var.weight <- (variances - var.min) / var.max
  
  weight_func <- function(rowA, rowB) {
    
    # weight_func takes as input two rows (thought of as rows of the UI matrix) and 
    # calculates the similarity between the two rows according to the chosen 'method'
    
    joint_values <- !is.na(rowA) & !is.na(rowB)
    if (sum(joint_values) == 0) {
      return(0)
    } else {
      if (method == 'pearson') {
        return(cor(rowA[joint_values], rowB[joint_values], method = 'pearson'))
      }
      if (method == 'psig') {
        if (sum(joint_values) < 50) {
          return(sum(joint_values)/50 * cor(rowA[joint_values], rowB[joint_values], method = 'pearson'))
        } else  {
          return(cor(rowA[joint_values], rowB[joint_values], method = 'pearson'))
        }
      }
      if (method == 'pvar') {
        return(corr(cbind(rowA[joint_values], rowB[joint_values]), w = var.weight[joint_values]))
      }
      if (method == 'spearman') {
        return(cor(rowA[joint_values], rowB[joint_values], method = 'spearman'))
      }
      if (method == 'vector') {
        return(cosine(rowA[joint_values], rowB[joint_values]))
      }
      if (method == 'entropy')  {
        entropy <- entropy(rowA[joint_values])
        cond.entropy <- condentropy(rowA[joint_values], rowB[joint_values])
        return(entropy - cond.entropy)
      }
      if (method == 'msd')  {
        return(1/(mean((rowA[joint_values] - rowB[joint_values])^2)))
      }
      if (method == 'simrank') {
        if (any(rowA > 1)) {
          rowA[rowA == 4 & rowA == 5 & rowA == 6] <- 1
          rowA[rowA == 3 & rowA == 2 & rowA == 1] <- 0
          rowB[rowB == 4 & rowB == 5 & rowB == 6] <- 1
          rowB[rowB == 3 & rowB == 2 & rowB == 1] <- 0
        }    
        c1 <- 0.8
        c2 <- 0.8
        outA <- sum(rowA, na.rm = TRUE)
        outB <- sum(rowB, na.rm = TRUE)
        common <- rowA == 1 & rowB == 1
        k <- sum(common, na.rm = TRUE)
        
        sim_users <- seq(0.001, 1, 0.001)
        
        for (i in 1:length(sim_users)) {
          sim1 <- sim_users[i]
          sim_items <- k + (outA - k)*(outB - k)*(c2 * sim1) + ((outA * outB) - k - (outA - k)*(outB - k))*(c2/2 * (1 + sim1))
          sim2 <- (c1 / (outA * outB)) * sim_items
          if (abs(sim1 - sim2) < 0.001) { break }
        }
        return(sim2)
      }
    }
  }
  
  # Loop over the rows and calculate all similarities using weight_func
  for(i in 1:nrow(data)) {
    weight_mat[i, ] <- apply(data, 1, weight_func, data[i, ])
    print(i)
  }
  if (method == 'simrank')  {
    diag(weight_mat) <- 1
  }
  return(round(weight_mat, 4))
}

pred_matrix <- function(data, simweights) {
  
  ## Calculate prediction matrix
  ## Extended to also return the number of predictions made
  ## Inputs: data       - movie data or MS data in user-item matrix form
  ##         simweights - a matrix of similarity weights
  ## Output: prediction matrix
  
  # Initiate the prediction matrix
  pred_mat <- data
  
  # Change MS entries from 0 to NA
  pred_mat[pred_mat == 0] <- NA
  
  row_avgs <- apply(data, 1, mean, na.rm = TRUE)
  
  for(i in 1:nrow(data)) {
    
    # Find columns we need to predict for user i and sim weights for user i
    cols_to_predict <- which(is.na(pred_mat[i, ]))
    num_cols        <- length(cols_to_predict)
    neighb_weights  <- simweights[i, ]
    
    # Transform the UI matrix into a deviation matrix since we want to calculate
    # weighted averages of the deviations
    dev_mat     <- data - matrix(rep(row_avgs, ncol(data)), ncol = ncol(data))
    weight_mat  <- matrix(rep(neighb_weights, ncol(data)), ncol = ncol(data))
    
    weight_sub <- weight_mat[, cols_to_predict]
    dev_sub    <- dev_mat[ ,cols_to_predict]
    
    pred_mat[i, cols_to_predict] <- row_avgs[i] +  apply(dev_sub * weight_sub, 2, sum, na.rm = TRUE)/sum(neighb_weights, na.rm = TRUE)
    print(i)
  }
  
  return(pred_mat)
}

test_movie_predictions <- function(pred_mat, test_UI){
  
  ## Calculates the Mean Absolute Error (MAE) of the movie predictions
  ## Inputs: pred_mat - matrix of predicted score made
  ##         test_UI  - UI matrix of test data. Unpredicted parts should 
  ##                    be set to NA to avoid interference in MAE calculation
  
  n_preds <- sum(!is.na(test_UI))
  pred_mat <- pred_mat[row.names(test_UI), colnames(test_UI)]
  MAE = sum(abs(pred_mat - test_UI),na.rm = T) / n_preds
  return(MAE)
}

test_MS_predictions <- function(pred_mat, test_UI, d=0.03, a=5){
  
  ## Calculates the rank score of Microsoft Predictions
  ## Inputs: pred_mat - matrix of predicted interest
  ##         test_UI  - UI matrix of test MS data
  ##         d - Interest threshold for entry into ranking
  ##         a - Half Life for expected view chance
  
  # Generates rankings from predicted preference strength
  f_rank <- function(x){rank(x, ties.method = 'first')}
  rank_pred <- ncol(pred_mat) - t(apply(pred_mat, 1, f_rank)) + 1
  rank_test <- ncol(MS_test_UI) - t(apply(MS_test_UI, 1, f_rank)) + 1
  
  # Generates max(v_aj - d, 0)
  modified_truth <- ifelse(MS_test_UI - d > 0, MS_test_UI - d, 0)
  
  sum_R_a = sum(1 / (2^((rank_pred[row.names(modified_truth), 
                                   colnames(modified_truth)]-1)/4)) 
                * modified_truth)
  sum_R_a_max = sum(1 / (2^((rank_test-1)/4)) * modified_truth)
  
  return(100 * sum_R_a / sum_R_a_max)
}
