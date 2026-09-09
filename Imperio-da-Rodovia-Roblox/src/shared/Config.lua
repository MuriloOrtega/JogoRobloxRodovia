return {
    DATASTORE_NAME = "ImperioDaRodovia_v1",
    BASE_REWARD = 10,
    CAR_INTERVAL = 4,
    MAX_LEVEL = 25,
    UPGRADE_BASE_COST = 100,
    STUDIO_PREVIEW_STAGES = true,

    -- Crie em Creator Dashboard > Monetization e substitua 0 pelo Asset ID.
    PASSES = {
        VIP = 0,
        GERENTE_AUTOMATICO = 0,
        RECEITA_EXTRA = 0,
        PERSONALIZACAO_PREMIUM = 0,
    },
    PRODUCTS = {
        CAIXA_PEQUENA = {id = 0, coins = 2500},
        CAIXA_MEDIA = {id = 0, coins = 9000},
        CAIXA_GRANDE = {id = 0, coins = 25000},
        OPERACAO_ACELERADA = {id = 0, duration = 15 * 60},
        REPARO_EMERGENCIAL = {id = 0},
    },
}
