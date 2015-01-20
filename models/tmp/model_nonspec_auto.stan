
data
{
	int<lower=1> n_obs;
	int<lower=1> n_subj;
	int<lower=1> n_item;
	int<lower=0,upper=2> iv_cond[n_obs];
	int<lower=0,upper=1> iv_questN1[n_obs];
	int<lower=1> crit_region_cnt[n_obs];
	int<lower=0,upper=1> response_yes[n_obs];
	real<lower=0> reading_time[n_obs];
	real<lower=0> response_RT[n_obs];
	int<lower=1,upper=n_subj> subj[n_obs];
	int<lower=1,upper=n_item> item[n_obs];
}

parameters
{
	real<lower=0,upper=1> p_uspec;
	real<lower=0,upper=1> p_att_n1;
	real<lower=0,upper=1> p_retrieval_fail;
	real<lower=0,upper=1> p_guess_yes;
	real<lower=0> rate;
	real<lower=0> alpha0;
	real<lower=0> alpha1;
	real<lower=0> alpha2;
	real<lower=0> beta0;
	real<lower=0> beta1;
	real p_uspec_subj[n_subj];
	real p_att_n1_subj[n_subj];
	real p_att_n1_item[n_item];
}

model
{
	int i;
	real prob_trial_type;
	real logProb_path;
	real reading_shape;
	real response_shape;
	real pY;
	real cur_p_uspec;
	real cur_p_att_n1;
	int cur_subj;
	int cur_item;
	
	for(i_obs in 1:n_obs)
	{
		cur_subj <- subj[i_obs];
		cur_item <- item[i_obs];
		cur_p_uspec <- inv_logit(logit(p_uspec) + p_uspec_subj[cur_subj]);
		cur_p_att_n1 <- inv_logit(logit(p_att_n1) + p_att_n1_subj[cur_subj] + p_att_n1_item[cur_item]);
		
		if(iv_cond[i_obs] == 0)
		{
			real logLik[5];
			
			// path: start0-start-cAMB-N1-GUESS;
			logProb_path <- log(((1 - cur_p_uspec) * cur_p_att_n1) * (p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1 + alpha2;
			pY <- p_guess_yes;
			response_shape <- response_shape + beta1;
			logLik[1] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			// path: start0-start-cAMB-N1-resp_N1;
			logProb_path <- log(((1 - cur_p_uspec) * cur_p_att_n1) * (1 - p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1 + alpha2;
			pY <- (iv_questN1[i_obs] == 1);
			logLik[2] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			// path: start0-start-cAMB-N2-GUESS;
			logProb_path <- log(((1 - cur_p_uspec) * (1 - cur_p_att_n1)) * (p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1;
			pY <- p_guess_yes;
			response_shape <- response_shape + beta1;
			logLik[3] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			// path: start0-start-cAMB-N2-resp_N2;
			logProb_path <- log(((1 - cur_p_uspec) * (1 - cur_p_att_n1)) * (1 - p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1;
			pY <- (iv_questN1[i_obs] == 0);
			logLik[4] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			// path: start0-start-cAMB-USPEC-GUESS;
			logProb_path <- log((cur_p_uspec));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			pY <- p_guess_yes;
			response_shape <- response_shape + beta1;
			logLik[5] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			increment_log_prob(log_sum_exp(logLik));
		};
		
		if(iv_cond[i_obs] == 1)
		{
			real logLik[2];
			
			// path: start0-start-cN1-N1-GUESS;
			logProb_path <- log((p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1 + alpha2;
			pY <- p_guess_yes;
			response_shape <- response_shape + beta1;
			logLik[1] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			// path: start0-start-cN1-N1-resp_N1;
			logProb_path <- log((1 - p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1 + alpha2;
			pY <- (iv_questN1[i_obs] == 1);
			logLik[2] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			increment_log_prob(log_sum_exp(logLik));
		};
		
		if(iv_cond[i_obs] == 2)
		{
			real logLik[2];
			
			// path: start0-start-cN2-N2-GUESS;
			logProb_path <- log((p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1;
			pY <- p_guess_yes;
			response_shape <- response_shape + beta1;
			logLik[1] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			// path: start0-start-cN2-N2-resp_N2;
			logProb_path <- log((1 - p_retrieval_fail));
			reading_shape <- alpha0 * crit_region_cnt[i_obs];
			response_shape <- beta0;
			reading_shape <- reading_shape + alpha1;
			pY <- (iv_questN1[i_obs] == 0);
			logLik[2] <- logProb_path + bernoulli_log(response_yes[i_obs], pY) + gamma_log(reading_time[i_obs], reading_shape, rate) + gamma_log(response_RT[i_obs], response_shape, rate);
			
			increment_log_prob(log_sum_exp(logLik));
		};
	};
}