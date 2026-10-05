--- STEAMODDED HEADER
--- MOD_NAME: Polytrans
--- MOD_ID: Polytrans
--- MOD_AUTHOR: [Lilaclila, Original mod by RadicaAprils, AutumnMood (it/she/they) and Eremel]
--- MOD_DESCRIPTION: Spectral cards but with the trans flag colours
--- PREFIX: tspa
--- VERSION: 1.2.0
--- DEPENDENCIES: [malverk]


Malverk.badges.spectrans = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('k_spectrans'), get_type_colour(self or card.config, card), nil, 1.2)
end
Malverk.badges.spectrans_card = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('k_spectrans_card'), get_type_colour(self or card.config, card), nil, 1.2)
end

AltTexture{
    key = 'spectral',
    set = 'Spectral',
    path = 'Spectrans-Tarots.png',
    soul = 'Enhancers-TSpectrals.png',
    original_sheet = true,
    display_pos = 'c_trance',
    localization = true
}

AltTexture{
    key = 'boosters',
    set = 'Booster',
    path = 'Spectrans-Boosters.png',
    original_sheet = true,
    keys = {
        'p_spectral_normal_1',
        'p_spectral_normal_2',
        'p_spectral_jumbo_1',
        'p_spectral_mega_1',
    },
    localization = true
}

AltTexture{
    key = 'tags',
    set = 'Tag',
    path = 'Tags-TSpectrals.png',
    original_sheet = true,
    keys = {
        'tag_ethereal'
    },
    localization = true
}

AltTexture{
    key = 'deck',
    set = 'Back',
    path = 'Enhancers-TSpectrals.png',
    keys = {'b_ghost'},
    original_sheet = true,
    localization = true
}

AltTexture{
    key = 'joker',
    set = 'Joker',
    path = 'Jokers-TSpectrals.png',
    keys = {'j_banner','j_seance'},
    original_sheet = true
}

AltTexture{
    key = 'hrt',
    set = 'Joker',
    path = 'HRT-TSpectrals.png',
    keys = {'j_hit_the_road'},
    localization = true
}

TexturePack{
    key = 'spectrans',
    textures = {
        'tspa_spectral',
        'tspa_boosters',
        'tspa_tags',
        'tspa_deck',
        'tspa_joker',
        'tspa_hrt',
        'tspa_edition'
    },
    localization = true
}

if AltTextures_Utils and AltTextures_Utils.loc_keys then
    AltTextures_Utils.loc_keys['Edition'] = 'b_editions'
    AltTextures_Utils.default_atlas['Edition'] = 'Joker'
end

AltTexture{
    key = 'edition',
    set = 'Edition',
    path = 'HRT-TSpectrals.png',
    keys = {'e_polychrome'}
}

SMODS.Shader{
    key = 'polytrans_card',
    path = 'polychrome.fs',
    prefix_config = { key = false },
}


Polytrans = Polytrans or {}

function Polytrans.is_pack_active()
    if not (Malverk and Malverk.config and Malverk.config.selected) then return false end
    for _, pack in ipairs(Malverk.config.selected) do
        if pack == 'polytrans' or pack == 'spectrans' or pack == 'tspa_spectrans' then return true end
    end
    return false
end

SMODS.Shader{
    key = 'polytrans_badge',
    path = 'polytrans_badge.fs',
    prefix_config = { key = false },
}

SMODS.Shader{
    key = 'polytrans_badge_white',
    path = 'polytrans_badge_white.fs',
    prefix_config = { key = false },
}

Polytrans.TEXT_CENTERS = {
    c_aura = true,
    c_hex = true,
    c_wheel_of_fortune = true,
    v_glow_up = true,
    v_hone = true,
}

function Polytrans.hrt_active()
    local ok, name = pcall(localize, { type = 'name_text', set = 'Joker', key = 'j_hit_the_road' })
    return ok and name == 'HRT'
end

function Polytrans.is_affected(card)
    if not card then return false end

    if card.edition and card.edition.polychrome then
        return false
    end

    local center = card.config and card.config.center
    local key = center and center.key
    if not key then return false end
    if Polytrans.TEXT_CENTERS[key] then return true end
    if key == 'j_hit_the_road' then return Polytrans.hrt_active() end
    return false
end

function Polytrans.create_badge()
    local shader_ok = G.SHADERS and G.SHADERS.polytrans_badge_white
    local badge = create_badge(localize('k_polytrans'), shader_ok and { 1, 1, 1, 1 } or HEX('E58BA6'), nil, 1)
    if shader_ok then
        badge.nodes[1].config.polytrans_shader = true
    end
    return badge
end

local ref_draw_self = UIElement.draw_self
function UIElement:draw_self()
    if self.config.polytrans_shader then
        local shader = G.SHADERS and G.SHADERS.polytrans_badge_white
        if shader then
            if shader:hasUniform('polytrans_time') then shader:send('polytrans_time', G.TIMERS.REAL) end
            if shader:hasUniform('unit_px') then shader:send('unit_px', G.TILESCALE * G.TILESIZE * (G.CANV_SCALE or 1)) end
            love.graphics.setShader(shader)
            ref_draw_self(self)
            love.graphics.setShader()
            return
        end
    end
    return ref_draw_self(self)
end

local ref_card_h_popup = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
    Polytrans.popup_card = card
    local ret = ref_card_h_popup(card)
    Polytrans.popup_card = nil
    return ret
end

-- look here argil
-- append badge when Steamodded builds the badges for that card
-- appending here means it is added AFTER the rarity/type badge and the edition badge
if SMODS.create_mod_badges then
    local ref_create_mod_badges = SMODS.create_mod_badges
    function SMODS.create_mod_badges(obj, badges)
        ref_create_mod_badges(obj, badges)
        local card = Polytrans.popup_card
        if card and obj and obj == (card.config and card.config.center) and Polytrans.is_affected(card) then
            badges[#badges + 1] = Polytrans.create_badge()
        end
    end
end



local ref_draw_shader = Sprite.draw_shader
function Sprite:draw_shader(shader, ...)
    if shader == 'polychrome' and Polytrans.is_pack_active() and G.SHADERS['polytrans_card'] then
        shader = 'polytrans_card'
    end
    return ref_draw_shader(self, shader, ...)
end

local ref_update_atlas = Malverk.update_atlas
function Malverk.update_atlas(...)
    if Polytrans.is_pack_active() then
        if G.localization.misc.labels.polychrome ~= 'Trans' then
            G.localization.misc.labels.polychrome = 'Trans'
            G.localization.descriptions.Edition.e_polychrome.name = 'Trans'
        end
    else
        if G.localization.misc.labels.polychrome == 'Trans' then
            G.localization.misc.labels.polychrome = 'Polychrome'
            G.localization.descriptions.Edition.e_polychrome.name = 'Polychrome'
        end
    end

    return ref_update_atlas(...)
end

