use anchor_lang::prelude::*;

// Program ID (will be generated after deployment)
declare_id!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

/// Counter Program - A simple Solana program demonstrating basic operations
#[program]
pub mod counter_program {
    use super::*;

    /// Initialize a new counter account
    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        counter.count = 0;
        counter.authority = *ctx.accounts.user.key;
        msg!("Counter initialized to 0");
        Ok(())
    }

    /// Increment the counter
    pub fn increment(ctx: Context<Update>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        counter.count = counter
            .count
            .checked_add(1)
            .ok_or(ErrorCode::Overflow)?;
        msg!("Counter incremented to {}", counter.count);
        Ok(())
    }

    /// Decrement the counter
    pub fn decrement(ctx: Context<Update>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        counter.count = counter
            .count
            .checked_sub(1)
            .ok_or(ErrorCode::Underflow)?;
        msg!("Counter decremented to {}", counter.count);
        Ok(())
    }

    /// Set counter to a specific value (only authority)
    pub fn set(ctx: Context<Update>, value: u64) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        require!(
            ctx.accounts.user.key() == counter.authority,
            ErrorCode::Unauthorized
        );
        counter.count = value;
        msg!("Counter set to {}", value);
        Ok(())
    }

    /// Reset the counter to zero (only authority)
    pub fn reset(ctx: Context<Update>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        require!(
            ctx.accounts.user.key() == counter.authority,
            ErrorCode::Unauthorized
        );
        counter.count = 0;
        msg!("Counter reset to 0");
        Ok(())
    }
}

/// Context for initializing the counter
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = user,
        space = 8 + Counter::INIT_SPACE
    )]
    pub counter: Account<'info, Counter>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

/// Context for updating the counter
#[derive(Accounts)]
pub struct Update<'info> {
    #[account(mut)]
    pub counter: Account<'info, Counter>,
    pub user: Signer<'info>,
}

/// Counter account structure
#[account]
#[derive(InitSpace)]
pub struct Counter {
    pub count: u64,      // Current count value
    pub authority: Pubkey, // Account with special permissions
}

/// Custom error codes
#[error_code]
pub enum ErrorCode {
    #[msg("Arithmetic overflow occurred")]
    Overflow,
    #[msg("Arithmetic underflow occurred")]
    Underflow,
    #[msg("Unauthorized access")]
    Unauthorized,
}
